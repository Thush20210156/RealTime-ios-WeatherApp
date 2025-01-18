//
//  TemperatureBar.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct TemperatureBar: View {
    let lowTemp: Int
    let highTemp: Int
    
    private func calculateGradient() -> Gradient {
        return Gradient(colors: [
            .blue.opacity(0.7),
            .orange.opacity(0.7)
        ])
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                // Temperature gradient bar
                Capsule()
                    .fill(LinearGradient(
                        gradient: calculateGradient(),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 4)
            }
        }
    }
}
