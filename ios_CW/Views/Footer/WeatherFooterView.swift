//
//  WeatherFooterView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI


struct WeatherFooterView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let selectedLocation: WeatherLocation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header section
            VStack(alignment: .leading, spacing: 8) {
                Text("Weather for \(selectedLocation.cityName), \(selectedLocation.region ?? "")")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Learn more about weather data and map data")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Divider()
                .background(Color.white.opacity(0.3))
                .padding(.horizontal)

            // Maps Button
            Button(action: {
                openInMaps(location: selectedLocation)
            }) {
                HStack {
                    Text("Open in Maps")
                        .font(.system(size: 18, weight: .medium))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            // Weather Summary Section
            if let weatherResponse = viewModel.weatherResponses[selectedLocation.id] {
                VStack(spacing: 16) {
                    Text("Current Conditions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 20) {
                        // Temperature Card
                        WeatherInfoCard(
                            icon: "thermometer",
                            title: "Temperature",
                            value: "\(Int(weatherResponse.current.temp))°C"
                        )
                        
                        // Condition Card
                        WeatherInfoCard(
                            icon: "cloud",
                            title: "Condition",
                            value: weatherResponse.current.weather.first?.description.capitalized ?? "N/A"
                        )
                    }
                    
                    HStack(spacing: 20) {
                        // Humidity Card
                        WeatherInfoCard(
                            icon: "humidity",
                            title: "Humidity",
                            value: "\(weatherResponse.current.humidity)%"
                        )
                        
                        // Wind Card
                        WeatherInfoCard(
                            icon: "wind",
                            title: "Wind",
                            value: "\(Int(weatherResponse.current.windSpeed)) km/h"
                        )
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                ProgressView()
                    .tint(.white)
                    .padding()
            }
        }
        .padding(.vertical)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
    }

    private func openInMaps(location: WeatherLocation) {
        let lat = location.lat
        let lon = location.lon
        let urlString = "https://www.google.com/maps/search/?q=\(lat),\(lon)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct WeatherInfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}
