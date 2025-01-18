//
//  AirQualityView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct AirQualityView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let selectedLocation: WeatherLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "aqi.high")
                    .foregroundColor(.white.opacity(0.7))
                Text("AIR QUALITY")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
            if let airQuality = viewModel.getAirQuality(for: selectedLocation.id),
               let currentAQI = airQuality.list.first?.main.aqi {
                // Main AQI Display
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.getAQIDescription(aqi: currentAQI))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.getAQIColor(aqi: currentAQI))
                    
                    Text("Air Quality Index: \(currentAQI)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Scrollable Components View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if let components = airQuality.list.first?.components {
                            AQIComponentCard(title: "PM2.5", value: components.pm2_5)
                            AQIComponentCard(title: "PM10", value: components.pm10)
                            AQIComponentCard(title: "NO2", value: components.no2)
                            AQIComponentCard(title: "O3", value: components.o3)
                            AQIComponentCard(title: "SO2", value: components.so2)
                            AQIComponentCard(title: "CO", value: components.co)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Loading air quality data...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

// Component Card for individual pollutants
struct AQIComponentCard: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
            
            Text(String(format: "%.1f", value))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("μg/m³")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// Preview Provider
struct AirQualityView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            AirQualityView(
                viewModel: WeatherViewModel(locationManager: LocationManager()),
                selectedLocation: WeatherLocation(
                    id: UUID(),
                    cityName: "Test City",
                    region: "Test Region",
                    temperature: 25,
                    condition: nil,
                    highTemp: 30,
                    lowTemp: 20,
                    time: nil,
                    isHomeLocation: false,
                    lat: 0.0,
                    lon: 0.0
                )
            )
            .padding()
        }
    }
}
