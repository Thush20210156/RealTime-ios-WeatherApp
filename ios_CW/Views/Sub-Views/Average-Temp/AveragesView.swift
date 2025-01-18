//
//  AveragesView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct AveragesView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 14))
                Text("AVERAGES")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
            
            if let dailyHighTemp = viewModel.dailyHighTemp,
               let averageDailyHigh = viewModel.averageDailyHigh {
                // Display the daily high temperature
                Text("+\(dailyHighTemp)°")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                // Determine if the daily high temperature is above or below the average
                let above = dailyHighTemp > Int(averageDailyHigh) ? "above" : "below"
                
                Text("\(above) average\ndaily high")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)  // Allow up to 2 lines
                    .fixedSize(horizontal: false, vertical: true)  // Allow vertical expansion
                    .lineSpacing(4)
                
                Spacer()
                
                // Display today's high and average high temperatures
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        Text("Average")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("H:\(dailyHighTemp)°")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("H:\(Int(averageDailyHigh))°")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            } else {
                // Show loading state if data is not available
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

#Preview {
    // Create a mock WeatherViewModel and WeatherLocation
    let mockViewModel = WeatherViewModel(locationManager: LocationManager())
    let mockLocation = WeatherLocation(
        id: UUID(),
        cityName: "Mock City",
        region: "Mock Region",
        temperature: 25,
        condition: "Clear",
        highTemp: 30,
        lowTemp: 20,
        time: "12:00 PM",
        isHomeLocation: false,
        lat: 0.0,
        lon: 0.0
    )
    
    // Provide mock data for daily high and average daily high
    mockViewModel.dailyHighTemp = 32
    mockViewModel.averageDailyHigh = 28.0
    
    return AveragesView(viewModel: mockViewModel, selectedLocation: mockLocation)
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
        .background(Color.gray)
}
