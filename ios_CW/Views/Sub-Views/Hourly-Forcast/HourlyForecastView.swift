//
//  HourlyForecastView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct HourlyForecastView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let selectedLocation: WeatherLocation
    
    private func formatHour(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if hour == calendar.component(.hour, from: Date()) {
            return "Now"
        }
        return "\(hour)"
    }
    
    private func formatSunset(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private var weatherSummary: String {
        if let weather = viewModel.weatherResponses[selectedLocation.id] {
            let condition = weather.current.weather.first?.description ?? ""
            let windSpeed = Int(weather.current.windSpeed * 3.6) // Convert m/s to km/h
            return "\(condition.capitalized) conditions will continue for the rest of the day. Wind gusts are up to \(windSpeed) km/h."
        }
        return ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Weather summary
            if !weatherSummary.isEmpty {
                Text(weatherSummary)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                    
            }
            
            Divider()
                .background(Color.white)
                .frame(height: 5)
                
            
            if let weatherData = viewModel.weatherResponses[selectedLocation.id] {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        // Current hour ("Now")
                        let currentTemp = Int(weatherData.current.temp)
                        HourlyItemView(
                            time: "Now",
                            icon: weatherData.current.weather.first?.icon ?? "01d",
                            temperature: currentTemp,
                            isSunset: false
                        )
                        
                        // Next hours
                        ForEach(Array(weatherData.hourly?.prefix(24) ?? []), id: \.dt) { hour in
                            if hour.dt == weatherData.current.sunset {
                                // Sunset item
                                HourlyItemView(
                                    time: formatSunset(hour.dt),
                                    icon: "sunset",
                                    label: "Sunset",
                                    temperature: Int(hour.temp),
                                    isSunset: true
                                )
                            } else {
                                HourlyItemView(
                                    time: formatHour(hour.dt),
                                    icon: hour.weather.first?.icon ?? "01d",
                                    temperature: Int(hour.temp),
                                    isSunset: false
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            } else {
                Text("Loading forecast...")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .onAppear {
            viewModel.updateDisplayForLocation(selectedLocation)
        }
    }
}

