//
//  DayForecastRow.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct DayForecastRow: View {
    var forecast: DayForecast
    let showPrecipitation: Bool
    
    var body: some View {
        HStack {
            // Day of the week
            Text(forecast.day)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
            
            // Precipitation percentage (if applicable)
            if showPrecipitation && forecast.precipitation ?? 0 > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("\(forecast.precipitation ?? 0)%")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                }
                .frame(width: 50, alignment: .leading)
            } else {
                Spacer()
                    .frame(width: 50)
            }
            
            // Weather icon
            WeatherIcon(iconCode: forecast.icon)
                .frame(width: 30)
            
            Spacer()
            
            // Temperature bar
            TemperatureBar(lowTemp: forecast.lowTemp, highTemp: forecast.highTemp)
                .frame(width: 120, height: 4)
            
            // Temperature values
            HStack(spacing: 4) {
                Text("\(forecast.lowTemp)°")
                    .foregroundColor(.cyan)
                Text("\(forecast.highTemp)°")
                    .foregroundColor(.white)
            }
            .font(.system(size: 16))
            .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
