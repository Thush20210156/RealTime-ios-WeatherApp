//
//  PrecipitationView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct PrecipitationView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    private func calculateTotalPrecipitation(_ hourlyData: [Hourly]?) -> Double {
        guard let hourlyData = hourlyData else { return 0.0 }
        return hourlyData.reduce(0.0) { total, hour in
            total + (hour.rain?.oneHour ?? 0.0)
        }
    }
    
    private func getExpectedPrecipitation(_ dailyData: [Daily]?) -> Double {
        guard let dailyData = dailyData else { return 0.0 }
        return dailyData.first?.rain ?? 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "drop.fill")
                    .font(.system(size: 14))
                Text("PRECIPITATION")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
            
            if let weather = viewModel.weatherResponses[selectedLocation.id] {
                // Total precipitation in last 24 hours
                let totalPrecipitation = calculateTotalPrecipitation(weather.hourly)
                Text("\(Int(totalPrecipitation)) mm")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("in last 24h")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                
                // Expected precipitation in the next 24 hours
                let expectedPrecipitation = getExpectedPrecipitation(weather.daily)
                if let probability = weather.daily?.first?.pop {
                    let probabilityPercentage = Int(probability * 100)
                    Text("\(Int(expectedPrecipitation)) mm expected")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(probabilityPercentage)% chance of rain")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("\(Int(expectedPrecipitation)) mm expected in\nnext 24h")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                }
            } else {
                Text("Loading...")
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .frame(width: 180, height: 180)
        .background(Color.black.opacity(0.4))
        .cornerRadius(20)
    }
}
