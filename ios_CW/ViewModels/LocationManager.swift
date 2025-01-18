//
//  LocationManager.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocationError: String?
    @Published var cityName: String?

   
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false

        // Request location permission when initialized
        requestLocationPermission()
    }

    
    func requestLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            print("DEBUG: Requesting location authorization...")
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("ERROR: Location services are disabled.")
            lastLocationError = "Location services are disabled."
        }
    }

   
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            lastLocationError = "Location services are disabled."
            return
        }

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("DEBUG: Starting location updates...")
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("ERROR: Location access denied.")
            lastLocationError = "Location access denied."
        case .notDetermined:
            print("DEBUG: Location authorization not determined.")
        @unknown default:
            print("ERROR: Unknown location authorization status.")
        }
    }

    func stopLocationUpdates() {
        print("DEBUG: Stopping location updates...")
        locationManager.stopUpdatingLocation()
    }

   
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationStatus = manager.authorizationStatus

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("DEBUG: Location authorization granted.")
                self.startLocationUpdates()
            case .denied, .restricted:
                print("ERROR: Location authorization denied.")
            case .notDetermined:
                print("DEBUG: Location authorization not determined. Requesting permission...")
                self.requestLocationPermission()
            @unknown default:
                print("ERROR: Unknown location authorization status.")
            }
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            print("DEBUG: Updated location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
            self.reverseGeocode(location: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                lastLocationError = "Location data is currently unavailable."
            case .denied:
                lastLocationError = "Location access denied."
            case .network:
                lastLocationError = "Network error while fetching location."
            default:
                lastLocationError = "Location error: \(error.localizedDescription)"
            }
        } else {
            lastLocationError = "Location error: \(error.localizedDescription)"
        }
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            if let error = error {
                print("ERROR: Reverse geocoding error: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.cityName = placemark.locality ?? placemark.subLocality ?? placemark.name
                    print("DEBUG: City name updated to \(self.cityName ?? "Unknown")")
                }
            }
        }
    }
}


extension CLAuthorizationStatus {
    var debugDescription: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}



