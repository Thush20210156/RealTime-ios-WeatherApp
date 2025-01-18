//
//  HourlyItemView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-16.
//

import SwiftUI

struct HourlyItemView: View {
    let time: String
    let icon: String
    var label: String?
    let temperature: Int
    let isSunset: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(time)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            if isSunset {
                Image(systemName: "sunset.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Text(label ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            } else {
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    case .failure(_):
                        Image(systemName: "cloud.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    case .empty:
                        ProgressView()
                            .frame(width: 30, height: 30)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            Text("\(temperature)°")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: 60)
    }
}
