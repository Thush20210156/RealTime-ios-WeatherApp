//
//  UVIndexView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct UVIndexView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                Text("UV INDEX")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.8))
            
            if let weather = viewModel.weatherResponses[selectedLocation.id] {
                let uvValue = weather.current.uvi
                
                // UV Index Value
                Text("\(Int(uvValue))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                // UV Description
                Text(viewModel.getUVDescription(for: uvValue))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                // UV Index Bar
                UVIndexBar(uvValue: uvValue)
                    .frame(height: 6)
                    .padding(.vertical, 4)
                
                // UV Advice
                Text(viewModel.getUVAdvice(for: uvValue))
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            } else {
                // Loading placeholder
                Text("Loading...")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
    }
}

