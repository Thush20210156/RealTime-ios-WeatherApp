//
//  AirQualityData.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation


struct AirQualityData: Codable {
    let coord: Coordinate
    let list: [AirQualityInfo]
}

struct Coordinate: Codable {
    let lon: Double
    let lat: Double
}


struct AirQualityInfo: Codable {
    let main: Main
    let components: Components
    let dt: Int
}


struct Main: Codable {
    let aqi: Int
}


struct Components: Codable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
    
    enum CodingKeys: String, CodingKey {
        case co, no, no2, o3, so2, pm2_5 = "pm2_5", pm10, nh3
    }
}
