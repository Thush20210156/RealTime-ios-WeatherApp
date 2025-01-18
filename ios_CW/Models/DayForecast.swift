//
//  DayForecast.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation

struct DayForecast: Identifiable ,Codable {
    let id = UUID()
    let day: String
    let icon: String
    let lowTemp: Int
    let highTemp: Int
    let precipitation: Int?
    
    init(day: String, icon: String, lowTemp: Int, highTemp: Int, precipitation: Int? = nil) {
        self.day = day
        self.icon = icon
        self.lowTemp = lowTemp
        self.highTemp = highTemp
        self.precipitation = precipitation
    }
}
