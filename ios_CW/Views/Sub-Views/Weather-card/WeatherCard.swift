//
//  WeatherCard.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    let location: WeatherLocation
    @Binding var selectedTab: Int
    let onTap: () -> Void
    
    private var isCurrentLocation: Bool {
        if let index = viewModel.weatherLocations.firstIndex(where: { $0.id == location.id }) {
            return index == 1
        }
        return false
    }
    
    private func getLocalTime(from response: WeatherResponse) -> String {
        guard let timezone = response.timezone,
              let timestamp = response.current.dt else {
            return "Loading..."
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: timezone)
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Location name and Current Location icon
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(location.cityName)
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            if isCurrentLocation {
                                HStack(spacing: 4) {
                                    Image(systemName: "house.fill")
                                    Text("Current Location")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Local time for the location
                        if let response = viewModel.weatherResponses[location.id] {
                            Text(getLocalTime(from: response))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Temperature
                    if let response = viewModel.weatherResponses[location.id] {
                        Text("\(Int(response.current.temp))°")
                            .font(.title)
                            .fontWeight(.medium)
                    } else {
                        Text("--°")
                            .font(.title)
                            .fontWeight(.medium)
                    }
                }
                
                // Weather condition and high/low temperature
                HStack {
                    if let response = viewModel.weatherResponses[location.id] {
                        Text(response.current.weather.first?.description.capitalized ?? "Unknown")
                    } else {
                        Text("Unknown")
                    }
                    Spacer()
                    if let response = viewModel.weatherResponses[location.id],
                       let high = response.daily?.first?.temp.max,
                       let low = response.daily?.first?.temp.min {
                        Text("H:\(Int(high))° L:\(Int(low))°")
                    } else {
                        Text("H:--° L:--°")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .foregroundColor(.white)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom button style for scaling effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
