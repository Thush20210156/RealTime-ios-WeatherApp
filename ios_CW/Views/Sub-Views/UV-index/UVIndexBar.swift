//
//  UVIndexBar.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct UVIndexBar: View {
    let uvValue: Double

    private func calculatePosition(for uvValue: Double, in width: CGFloat) -> CGFloat {
        let maxUV = 11.0
        return min(CGFloat(uvValue / maxUV) * width, width)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Gradient Background
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .yellow, .orange, .red, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)

                // Indicator Circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(x: calculatePosition(for: uvValue, in: geometry.size.width) - 5)
            }
        }
    }
}
