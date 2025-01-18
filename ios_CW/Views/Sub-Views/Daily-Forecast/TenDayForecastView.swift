//
//  TenDayForecastView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI


struct TenDayForecastView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let selectedLocation: WeatherLocation
    
    private func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Single letter day format
        return formatter.string(from: date)
    }
    
    private func createDayForecast(from daily: Daily) -> DayForecast {
        return DayForecast(
            day: formatDate(daily.dt),
            icon: daily.weather.first?.icon ?? "01d",
            lowTemp: Int(daily.temp.min.rounded()),
            highTemp: Int(daily.temp.max.rounded()),
            precipitation: daily.pop.map { Int($0 * 100) }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                Text("DAILY FORECAST")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(.bottom, 8)
            
            if let weatherData = viewModel.weatherResponses[selectedLocation.id],
               let dailyForecasts = weatherData.daily {
                
                VStack(spacing: 0) {
                    ForEach(Array(dailyForecasts.prefix(10)), id: \.dt) { daily in
                        let forecast = createDayForecast(from: daily)
                        DayForecastRow(
                            forecast: forecast,
                            showPrecipitation: daily.pop ?? 0 > 0
                        )
                        
                        if daily.dt != dailyForecasts.prefix(10).last?.dt {
                            Divider()
                                .background(Color.white.opacity(0.2))
                        }
                    }
                }
            } else {
                Text("Loading forecast data...")
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
