//
//  VisibilityView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct VisibilityView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let selectedLocation: WeatherLocation
    
    var body: some View {
        if let weatherResponse = viewModel.weatherResponses[selectedLocation.id],
           let visibility = weatherResponse.hourly?.first?.visibility{ // Visibility in meters
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 14))
                    Text("VISIBILITY")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.7))
                
                // Display visibility converted to kilometers
                Text("\(visibility / 1000) km")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                // Weather description
                Text(weatherResponse.current.weather.first?.description ?? "No description available")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            .padding(20)
            .frame(width: 180, height: 180)
            .background(Color.black.opacity(0.4))
            .cornerRadius(20)
        } else {
            Text("Loading...")
                .foregroundColor(.white)
                .padding()
                .frame(width: 180, height: 180)
                .background(Color.black.opacity(0.4))
                .cornerRadius(20)
        }
    }
}
