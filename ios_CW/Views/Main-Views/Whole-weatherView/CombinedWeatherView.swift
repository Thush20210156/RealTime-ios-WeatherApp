//
//  CombinedWeatherView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct CombinedWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    @State private var buttonStatus: String = "Add"
    @Environment(\.dismiss) var dismiss
    var onClose: (() -> Void)?
    
    
    
    
    init(viewModel: WeatherViewModel, selectedLocation: WeatherLocation, onClose: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.selectedLocation = selectedLocation
        self.onClose = onClose
        
        // Initialize button status based on whether location is saved
        let isLocationSaved = viewModel.weatherLocations.contains { savedLocation in
            savedLocation.lat == selectedLocation.lat &&
            savedLocation.lon == selectedLocation.lon &&
            savedLocation.id != selectedLocation.id
        }
        self._buttonStatus = State(initialValue: isLocationSaved ? "Added" : "Add")
    }
    
    
    
    
    
    // Check if this location is at index 1 (current location tab)
    private var isCurrentLocation: Bool {
        if let index = viewModel.weatherLocations.firstIndex(where: { $0.id == selectedLocation.id }) {
            return index == 1
        }
        return false
    }
    
    
    // Computed property to check if location is saved
    private var isLocationSaved: Bool {
        viewModel.weatherLocations.contains { savedLocation in
            savedLocation.lat == selectedLocation.lat &&
            savedLocation.lon == selectedLocation.lon &&
            savedLocation.id != selectedLocation.id
        }
    }
    
    
    
    
    private func getVideoName(condition: String) -> String {
        if let weatherResponse = viewModel.getWeatherResponse(for: selectedLocation),
           let weatherCondition = weatherResponse.current.weather.first?.description.lowercased() {
            switch weatherCondition {
            case "clear sky":
                return "normal.mp4"
            case "light rain", "moderate rain", "heavy rain":
                return "Rainy.mp4"
            case "snow", "light snow":
                return "snowy.mp4"
            case "overcast clouds", "broken clouds", "partly cloudy":
                return "cloudyy.mp4"
            case "mist":
                return "misty.mp4"
            default:
                return "normal.mp4"
            }
        }
        return "normal.mp4"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Video
                VideoPlayerView(videoName: getVideoName(condition: selectedLocation.condition ?? "Unknown"))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.2).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Only show buttons for non-current location tabs
                    if !isCurrentLocation {
                        HStack {
                            Button("Cancel") {
                                dismiss()
                               // onClose?()
                            }
                            .foregroundColor(isLocationSaved ? .gray : .white)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .disabled(isLocationSaved) // Disable cancel button for saved locations
                            
                            Spacer()
                            
                            Button(buttonStatus) {
                                if buttonStatus == "Add" {
                                    let geoLocation = GeoLocation(
                                        name: selectedLocation.cityName,
                                        lat: selectedLocation.lat,
                                        lon: selectedLocation.lon,
                                        country: selectedLocation.region ?? "",
                                        state: selectedLocation.region
                                    )
                                    viewModel.addLocation(geoLocation)
                                    buttonStatus = "Added"
                                }
                            }
                            .foregroundColor(buttonStatus == "Added" ? .gray : .white)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        }
                        .frame(height: 44)
                        .padding(.top, geometry.safeAreaInsets.top)
                        .background(Color.black.opacity(0.01))
                    }
                    
                    // Weather content - Always visible
                    ScrollView {
                        VStack(spacing: 20) {
                            if viewModel.isLoading {
                                ProgressView("Fetching Weather Data...")
                                    .foregroundColor(.white)
                            } else if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            } else {
                                // Weather Header
                                WeatherHeaderView(weatherViewModel: viewModel, selectedLocation: selectedLocation)
                                    .padding(.top, isCurrentLocation ? geometry.safeAreaInsets.top + 20 : 0)
                                
                                // Hourly Forecast
                                HourlyForecastView(viewModel: viewModel, selectedLocation: selectedLocation)
                                
                                // Daily Forecast
                                TenDayForecastView(viewModel: viewModel, selectedLocation: selectedLocation)
                                
                                // Weather Details Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    AveragesView(viewModel: viewModel, selectedLocation: selectedLocation)
                                        .frame(maxWidth: .infinity)
                                    
                                        .cornerRadius(16)
                                    
                                    FeelsLikeView(viewModel: viewModel, selectedLocation: selectedLocation)
                                        .frame(maxWidth: .infinity)
                                    
                                        .cornerRadius(16)
                                    
                                    
                                    
                                    
                                    
                                    
                                    PrecipitationView(viewModel: viewModel, selectedLocation: selectedLocation)
                                        .frame(maxWidth: .infinity)
                                    
                                        .cornerRadius(16)
                                    
                                    MoonPhaseView(viewModel: viewModel, selectedLocation: selectedLocation)
                                        .frame(maxWidth: .infinity)
                                    
                                        .cornerRadius(16)
                                    
                                    HumidityView(viewModel: viewModel, selectedLocation: selectedLocation)
                                        .frame(maxWidth: .infinity)
                                    
                                        .cornerRadius(16)
                                    
                                    PressureView(viewModel: viewModel, selectedLocation: selectedLocation)
                                        .frame(maxWidth: .infinity)
                                    
                                        .cornerRadius(16)
                                    
                                    
                                    
                                    
                                }
                                
                                SunsetSunriseView(viewModel: viewModel, selectedLocation: selectedLocation)
                                
                                
                                UVIndexView(viewModel: viewModel, selectedLocation: selectedLocation)
                                
                                AirQualityView(viewModel: viewModel, selectedLocation: selectedLocation)
                                
                                // Footer
                                WeatherFooterView(viewModel: viewModel, selectedLocation: selectedLocation)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .onAppear {
            
            // Fetch weather data
            viewModel.fetchWeather(lat: selectedLocation.lat, lon: selectedLocation.lon, for: selectedLocation.id)
            
            
            // Handle location updates
            if isCurrentLocation {
                viewModel.locationManager.startLocationUpdates()
            } else {
                viewModel.locationManager.stopLocationUpdates()
            }
            
            
            
        }
    }
}
