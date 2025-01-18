//
//  WeatherHeaderView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct WeatherHeaderView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    
    // Check if this location is the current location (index 1)
        private var isCurrentLocation: Bool {
            if let index = weatherViewModel.weatherLocations.firstIndex(where: { $0.id == selectedLocation.id }) {
                return index == 1
            }
            return false
        }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Location Type and Name
                      HStack {
                          Image(systemName: isCurrentLocation ? "house.fill" : "location.fill")
                              .foregroundColor(isCurrentLocation ? .white : .teal)
                          
                          Text(isCurrentLocation ? "HOME LOCATION" : "LOCATION")
                              .font(.headline)
                              .foregroundColor(.white)
                      }

        

            Text(selectedLocation.cityName)
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)

            // Temperature and Condition
            if let weatherResponse = weatherViewModel.weatherResponses[selectedLocation.id] {
                Text("\(Int(weatherResponse.current.temp))°")
                    .font(.system(size: 96, weight: .thin))
                    .foregroundColor(.white)

                Text((weatherResponse.current.weather.first?.description ?? "Unknown").capitalized)
                    .font(.title3)
                    .padding(.top, 4)
                    .foregroundColor(.white)

                // High and Low Temperature
                HStack {
                    Text("H: \(Int(weatherResponse.daily?.first?.temp.max ?? 0))°")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)

                    Text("L: \(Int(weatherResponse.daily?.first?.temp.min ?? 0))°")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
            } else {
                // Fallback during loading
                Text("Loading weather data...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.7), .white.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
        .shadow(radius: 10)
        .onAppear{
            weatherViewModel.locationManager.stopLocationUpdates()
            print("DEBUG: Displaying cityName: \(weatherViewModel.currentCityName ?? "Unknown")")

        }
      .onAppear {
        // Only stop location updates if this isn't the current location
        if !isCurrentLocation {
            weatherViewModel.locationManager.stopLocationUpdates()
        }
        print("DEBUG: Displaying cityName: \(weatherViewModel.currentCityName ?? "Unknown")")
    }
    }
}

//Preview check with mock data

struct WeatherHeaderView_Preview: View {
    @StateObject private var mockViewModel = WeatherViewModel(locationManager: LocationManager())
    private let mockLocation = WeatherLocation(
        id: UUID(),
        cityName: "Mock City",
        region: "Mock Region",
        temperature: 25,
        condition: "Partly Cloudy",
        highTemp: 30,
        lowTemp: 20,
        time: "12:00 PM",
        isHomeLocation: true,
        lat: 0.0,
        lon: 0.0
    )

    init() {
       
        let mockCurrent = Current(
            dt: 1677000000,
            sunrise: 1676960400,
            sunset: 1677007200,
            temp: 25.0,
            feelsLike: 27.0,
            pressure: 1012,
            humidity: 65,
            dewPoint: 20.0,
            uvi: 5.0,
            clouds: 40,
            windSpeed: 15.0,
            windDeg: 270,
            weather: [Weather(id: 1, main: "Clouds", description: "Partly cloudy", icon: "03d")],
            rain: nil
        )

        let mockDaily = Daily(
            dt: 1677000000,
            sunrise: 1676960400,
            sunset: 1677007200,
            moonrise: 1676980000,
            moonset: 1677024000,
            moonPhase: 0.5,
            summary: "Clear sky",
            temp: Temp(day: 25.0, min: 20.0, max: 30.0, night: 22.0, eve: 26.0, morn: 21.0),
            feelsLike: FeelLike(day: 27.0, night: 22.0, eve: 26.0, morn: 21.0),
            pressure: 1012,
            humidity: 65,
            dewPoint: 20.0,
            windSpeed: 15.0,
            windDeg: 270,
            windGust: 25.0,
            weather: [Weather(id: 1, main: "Clear", description: "Clear sky", icon: "01d")],
            clouds: 10,
            pop: 0.0,
            rain: nil,
            snow: nil,
            uvi: 5.0
        )

        let mockWeatherResponse = WeatherResponse(
            lat: 0.0,
            lon: 0.0,
            timezone: "UTC",
            timezoneOffset: 0,
            current: mockCurrent,
            minutely: nil,
            hourly: nil,
            daily: [mockDaily],
            alerts: nil
        )

        // Set mock data in the view model
        mockViewModel.weatherResponses[mockLocation.id] = mockWeatherResponse
        mockViewModel.currentCityName = "Mock City"
    }

    var body: some View {
        WeatherHeaderView(weatherViewModel: mockViewModel, selectedLocation: mockLocation)
            .padding()
            .background(Color.gray.opacity(0.5))
            .previewLayout(.sizeThatFits)
    }
}

#Preview {
    WeatherHeaderView_Preview()
}

