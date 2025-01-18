//
//  SunCurveView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct SunCurveView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    private func calculateSunPosition(sunrise: Int, sunset: Int, current: Int, width: CGFloat) -> CGFloat {
        let totalDuration = sunset - sunrise
        let elapsedTime = current - sunrise
        let progress = CGFloat(elapsedTime) / CGFloat(totalDuration)
        return max(0, min(progress * width, width)) // Ensure position is within bounds
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sun curve
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height),
                        control: CGPoint(x: width / 2, y: height * 0.3)
                    )
                }
                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                
                if let response = viewModel.weatherResponses[selectedLocation.id],
                   let sunrise = response.current.sunrise,
                   let sunset = response.current.sunset,
                   let currentTime = response.current.dt {
                    // Sun position
                    let sunX = calculateSunPosition(
                        sunrise: sunrise,
                        sunset: sunset,
                        current: currentTime,
                        width: geometry.size.width
                    )
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 12, height: 12)
                        .position(x: sunX, y: geometry.size.height * 0.3)
                    
                    // Labels for sunrise and sunset
                    Text(viewModel.formatTime(from: sunrise))
                        .font(.caption)
                        .foregroundColor(.white)
                        .position(x: 10, y: geometry.size.height - 10)
                    
                    Text(viewModel.formatTime(from: sunset))
                        .font(.caption)
                        .foregroundColor(.white)
                        .position(x: geometry.size.width - 30, y: geometry.size.height - 10)
                } else {
                    Text("Loading...")
                        .foregroundColor(.white)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
        .frame(height: 50)
        .padding(16)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
    }
}
