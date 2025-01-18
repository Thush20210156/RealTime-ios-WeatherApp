//
//  HumidityView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct HumidityView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "humidity.fill")
                    .font(.system(size: 14))
                Text("HUMIDITY")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
            
            // Access humidity and dewPoint directly
            if let humidity = viewModel.humidity, let dewPoint = viewModel.dewPoint {
                Text("\(humidity)%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("The dew point is \(dewPoint)° right now.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
            } else {
                Text("Loading data...")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .frame(width: 180, height: 210)
        .background(Color.black.opacity(0.4))
        .cornerRadius(20)
    }
}
