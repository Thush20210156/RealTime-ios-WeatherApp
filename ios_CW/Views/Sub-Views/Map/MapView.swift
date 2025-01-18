//
//  MapView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
        @State private var region: MKCoordinateRegion
        @Environment(\.dismiss) private var dismiss
        
        init(weatherViewModel: WeatherViewModel) {
            self.weatherViewModel = weatherViewModel
            
            // Get initial coordinates
            let initialLat: Double
            let initialLon: Double
            
            if weatherViewModel.weatherLocations.indices.contains(1) {
                initialLat = weatherViewModel.weatherLocations[1].lat
                initialLon = weatherViewModel.weatherLocations[1].lon
            } else {
                initialLat = weatherViewModel.locationManager.latitude ?? 0
                initialLon = weatherViewModel.locationManager.longitude ?? 0
            }
            
            self._region = State(wrappedValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: initialLat, longitude: initialLon),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            ))
        }
        
  
        
        var body: some View {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true,
                    annotationItems: annotationItems) { item in
                    MapAnnotation(
                        coordinate: item.coordinate
                    ) {
                        switch item.location {
                        case .weather(let weatherLocation):
                            WeatherMarker(location: weatherLocation)
                                .onTapGesture {
                                    handleLocationSelection(weatherLocation)
                                }
                        case .tourist(let touristLocation):
                            TouristMarker(title: touristLocation.title ?? "")
                        }
                    }
                }
                .preferredColorScheme(.dark)
                
                VStack {
                    TopControlsView(dismiss: dismiss)
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if weatherViewModel.weatherLocations.indices.contains(1) {
                    updateMapForLocation(weatherViewModel.weatherLocations[1])
                }
            }
            .onChange(of: weatherViewModel.selectedLocationId) { newLocationId in
                       handleLocationIdChange(newLocationId)
                   }
                   .onReceive(weatherViewModel.$weatherLocations) { _ in
                       if let selectedId = weatherViewModel.selectedLocationId,
                          let selectedLocation = weatherViewModel.weatherLocations.first(where: { $0.id == selectedId }) {
                           updateMapForLocation(selectedLocation)
                       }
                   }
               }
    
    // Supporting types and views
    enum LocationType {
        case weather(WeatherLocation)
        case tourist(MapLocation)
    }

    struct LocationAnnotationItem: Identifiable {
        let id = UUID()
        let location: LocationType
        
        var coordinate: CLLocationCoordinate2D {
            switch location {
            case .weather(let weatherLocation):
                return CLLocationCoordinate2D(latitude: weatherLocation.lat, longitude: weatherLocation.lon)
            case .tourist(let touristLocation):
                return CLLocationCoordinate2D(latitude: touristLocation.latitude, longitude: touristLocation.longitude)
            }
        }
    }

    struct TopControlsView: View {
        let dismiss: DismissAction
        
        var body: some View {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    LegendItem(color: .blue, text: "Weather")
                    LegendItem(color: .green, text: "Attractions")
                }
                .padding()
            }
            .padding(.horizontal)
            .background(Color.black.opacity(0.5))
        }
    }
    
    private var annotationItems: [LocationAnnotationItem] {
        // Get all locations except index 0, starting from index 1 (current location)
        let weatherLocations = weatherViewModel.weatherLocations.enumerated()
            .filter { index, _ in index > 0 } // Filter out index 0
            .map { $0.element }
        
        // Create annotation items for weather locations and tourist locations
        return weatherLocations.map { LocationAnnotationItem(location: .weather($0)) } +
               weatherViewModel.touristLocations.map { LocationAnnotationItem(location: .tourist($0)) }
    }
   

    // Update the handleLocationIdChange method to handle all valid locations
    private func handleLocationIdChange(_ newLocationId: UUID?) {
        if let newLocationId = newLocationId,
           let selectedLocation = weatherViewModel.weatherLocations.first(where: { $0.id == newLocationId }) {
            // Update map for any location except index 0
            if let index = weatherViewModel.weatherLocations.firstIndex(where: { $0.id == selectedLocation.id }) {
                if index > 0 {
                    updateMapForLocation(selectedLocation)
                }
            }
        }
    }
    
    private func handleLocationSelection(_ location: WeatherLocation) {
        // Only handle non-index-0 locations
        if let index = weatherViewModel.weatherLocations.firstIndex(where: { $0.id == location.id }),
           index > 0 {
            weatherViewModel.selectedLocationId = location.id
            updateMapForLocation(location)
        }
    }
    
    private func updateMapForLocation(_ location: WeatherLocation) {
        withAnimation {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: location.lat,
                    longitude: location.lon
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.5,
                    longitudeDelta: 0.5
                )
            )
        }
        
        let geoLocation = location.toGeoLocation()
        weatherViewModel.fetchTouristAttractions(for: geoLocation)
    }
}

struct WeatherMarker: View {
    let location: WeatherLocation
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 2)
                
                Text("\(location.temperature)°")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(location.cityName)
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
        }
    }
}

struct TouristMarker: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 24))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .foregroundColor(.white)
                .font(.caption)
        }
    }
}
