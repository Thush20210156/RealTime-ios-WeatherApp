//
//  WeatherTabView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct WeatherTabView: View {
    @Binding var selectedTab: Int
    // @Binding var selectedLocations: [GeoLocation]
    let tabCount: Int
    @ObservedObject var weatherViewModel: WeatherViewModel
    
    @State private var showWeatherSearch = false
    @State private var showMapView = false
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    ForEach(weatherViewModel.weatherLocations.indices, id: \.self) { index in
                        let location = weatherViewModel.weatherLocations[index]
                        
                        CombinedWeatherView(
                            viewModel: weatherViewModel,
                            selectedLocation: location,
                            onClose: {
                                //only allow removal of non-current locations
                                if index != 0 {
                                    removeLocation(at: index)
                                }
                            }
                        )
                        .tag(index)
                    }
                }
                .onChange(of: selectedTab) { newValue in
                    print("DEBUG: Selected tab changed to \(newValue)")
                    
                    if newValue == 0 {
                        selectedTab = 1
                    }
                    print("DEBUG: Selected tab changed to \(selectedTab)")
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.8)
                    
                    HStack {
                        Button(action: {
                            showMapView = true
                        }) {
                            Image(systemName: "map")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .padding(.all)
                        }
                        .sheet(isPresented: $showMapView) {
                            MapView(
                                weatherViewModel: weatherViewModel)
                        }.onAppear() {
                            weatherViewModel.loadSavedLocations()
                        }
                        
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ForEach(weatherViewModel.weatherLocations.indices.dropFirst(), id: \.self) { index in
                                Group {
                                    if index == 1 {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(index == selectedTab ? .white : .white.opacity(0.5))
                                            .font(.system(size: 16))
                                    }else {
                                        Circle()
                                            .fill(index == selectedTab ? Color.white : Color.white.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .onTapGesture {
                                    selectedTab = index
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showWeatherSearch = true
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(.all)
                        }
                        .sheet(isPresented: $showWeatherSearch) {
                            WeatherSearchView(
                                viewModel: weatherViewModel,
                                selectedLocations: Binding(
                                    get: { weatherViewModel.weatherLocations.map { $0.geoLocation } },
                                    set: { newLocations in
                                        weatherViewModel.updateLocations(from: newLocations)
                                    }
                                ),
                                selectedTab: $selectedTab
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .frame(height: 80)
            }
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                setupInitialLocation()
                
                if selectedTab == 0 {
                    selectedTab = 1
                }
            }
        }
    }
    
    
    
    private func setupInitialLocation() {
        // Load saved weather cards first
        weatherViewModel.loadWeatherCards()
        
        // Check if we need to add current location
        if weatherViewModel.weatherLocations.isEmpty {
            if let latitude = locationManager.latitude,
               let longitude = locationManager.longitude {
                let geoLocation = GeoLocation(
                    name: locationManager.cityName ?? "Current Location",
                    lat: latitude,
                    lon: longitude,
                    country: "",
                    state: nil
                )
                weatherViewModel.addLocation(geoLocation)
            }
        } else {
            // Update current location if it exists
            if let latitude = locationManager.latitude,
               let longitude = locationManager.longitude {
                if var currentLocation = weatherViewModel.weatherLocations.first {
                    currentLocation.lat = latitude
                    currentLocation.lon = longitude
                    if let cityName = locationManager.cityName {
                        currentLocation.cityName = cityName
                    }
                    // Update the first location
                    if !weatherViewModel.weatherLocations.isEmpty {
                        weatherViewModel.weatherLocations[0] = currentLocation
                        weatherViewModel.fetchWeather(lat: latitude, lon: longitude, for: currentLocation.id)
                    }
                }
            }
        }
    }
    
    private func removeLocation(at index: Int) {
        // Prevent removal of current location
        guard index != 0 else { return }
        
        weatherViewModel.weatherLocations.remove(at: index)
        weatherViewModel.saveWeatherCards()
        
        if selectedTab >= weatherViewModel.weatherLocations.count {
            selectedTab = max(0, weatherViewModel.weatherLocations.count - 1)
        }
    }
}
