//
//  ios_CWApp.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

@main
struct ios_CWApp: App {
    @StateObject private var locationManager = LocationManager() // To manage location fetching
    @StateObject private var weatherViewModel: WeatherViewModel
    @State private var selectedTab = 0

    init() {
        // Initialize WeatherViewModel with the LocationManager
        let manager = LocationManager()
        _weatherViewModel = StateObject(wrappedValue: WeatherViewModel(locationManager: manager))
    }

    var body: some Scene {
        WindowGroup {
            WeatherTabView(selectedTab: $selectedTab, tabCount: 3, weatherViewModel: weatherViewModel)
                .onAppear {
                    checkLocationAuthorization()
                }
        }
    }

    private func checkLocationAuthorization() {
        DispatchQueue.global(qos: .background).async {
            let authorizationStatus = locationManager.locationStatus

            DispatchQueue.main.async {
                if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                    print("DEBUG: Location authorization granted.")
                } else {
                    print("DEBUG: Requesting location authorization.")
                    locationManager.requestLocationPermission()
                }
            }
        }
    }
}
