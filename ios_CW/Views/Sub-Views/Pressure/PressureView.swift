//
//  PressureView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct PressureView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "gauge.medium")
                    .foregroundColor(.white.opacity(0.7))
                Text("PRESSURE")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(Color.white.opacity(0.6), lineWidth: 10)
                    .frame(width: 120, height: 120)
                    .rotationEffect(Angle(degrees: 180))

                VStack(spacing: 0) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    let pressure = viewModel.getPressure(for: selectedLocation)
                    Text("\(pressure)") // Default to 0 if nil
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("hPa")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }

            HStack {
                Text("Low")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("High")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.4))
        .cornerRadius(20)
        .frame(width: 180, height: 220)
    }
}
