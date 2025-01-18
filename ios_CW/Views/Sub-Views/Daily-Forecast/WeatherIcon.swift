//
//  WeatherIcon.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-16.
//

import SwiftUI

struct WeatherIcon: View {
    let iconCode: String
    
    var body: some View {
        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .scaledToFit()
            case .failure(_):
                Image(systemName: "cloud.fill")
                    .foregroundColor(.white)
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
    }
}
