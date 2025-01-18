//
//  SunsetSunriseView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct SunsetSunriseView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sunset.fill")
                    .foregroundColor(.yellow)
                Text("SUNSET & SUNRISE")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            if let response = viewModel.weatherResponses[selectedLocation.id] {
                let sunrise = response.current.sunrise
                let sunset = response.current.sunset
                
                // Sunset Time
                Text(viewModel.formatTime(from: sunset ?? 0))
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
                
                // Sun Curve
                SunCurveView(viewModel: viewModel, selectedLocation: selectedLocation)
                    .frame(height: 100)
                
                // Sunrise Time
                HStack {
                    Text("Sunrise:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Text(viewModel.formatTime(from: sunrise ?? 0))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Day Length
                let dayLength = (sunset ?? 0) - (sunrise ?? 0)
                let hours = dayLength / 3600
                let minutes = (dayLength % 3600) / 60
                Text("Length of day: \(hours)h \(minutes)m")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            } else {
                Text("Loading...")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
       
        .cornerRadius(16)
    }
}
