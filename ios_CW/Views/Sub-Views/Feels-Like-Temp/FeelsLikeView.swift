//
//  FeelsLikeView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//


import SwiftUI

struct FeelsLikeView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation  
    
    private func getFeelsLikeDescription(actual: Int?, feelsLike: Int?) -> String {
        guard let actual = actual, let feelsLike = feelsLike else {
            return "Calculating..."
        }
        let difference = abs(actual - feelsLike)
        if difference < 1 {
            return "Similar to actual temperature"
        } else if feelsLike > actual {
            return "Feels warmer due to humidity"
        } else {
            return "Feels colder due to wind"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "thermometer")
                Text("FEELS LIKE")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
            }
            .foregroundColor(.white.opacity(0.7))
            
            // Display data
            if let weatherResponse = viewModel.weatherResponses[selectedLocation.id] {
                let feelsLikeTemp = Int(weatherResponse.current.feelsLike)
                let actualTemp = Int(weatherResponse.current.temp)
                
                // Current feels-like temperature
                Text("\(feelsLikeTemp)°")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Description
                Text(getFeelsLikeDescription(
                    actual: actualTemp,
                    feelsLike: feelsLikeTemp
                ))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)  // Allow up to 2 lines
                .fixedSize(horizontal: false, vertical: true)  // Allow vertical expansion
                
                .lineSpacing(4)
                
                // Additional weather factors
                Text("Humidity: \(weatherResponse.current.humidity)%")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Wind: \(Int(weatherResponse.current.windSpeed)) km/h")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            } else {
                Text("Loading temperature data...")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(width: 180, height: 180)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
    }
}

// Preview Provider
struct FeelsLikeView_Preview: View {
    @StateObject private var mockViewModel = WeatherViewModel(locationManager: LocationManager())
    
    init() {
        let mockLocation = WeatherLocation(
            id: UUID(),
            cityName: "Mock City",
            region: nil,
            temperature: 28,
            condition: "Clear",
            highTemp: 30,
            lowTemp: 20,
            time: "12:00",
            isHomeLocation: false,
            lat: 0.0,
            lon: 0.0
        )
        
        let mockCurrent = Current(
            dt: 1677000000,
            sunrise: 1676960400,
            sunset: 1677007200,
            temp: 28.0,
            feelsLike: 30.0,
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
        
        let mockWeatherResponse = WeatherResponse(
            lat: 0.0,
            lon: 0.0,
            timezone: "UTC",
            timezoneOffset: 0,
            current: mockCurrent,
            minutely: nil,
            hourly: nil,
            daily: nil,
            alerts: nil
        )
        
        // Set mock data
        mockViewModel.weatherResponses[mockLocation.id] = mockWeatherResponse
    }
    
    var body: some View {
        FeelsLikeView(
            viewModel: mockViewModel,
            selectedLocation: WeatherLocation(
                id: UUID(),
                cityName: "Mock City",
                region: nil,
                temperature: 28,
                condition: "Clear",
                highTemp: 30,
                lowTemp: 20,
                time: "12:00",
                isHomeLocation: false,
                lat: 0.0,
                lon: 0.0
            )
        )
        .padding()
        .background(Color.gray.opacity(0.8))
        .previewLayout(.sizeThatFits)
    }
}
