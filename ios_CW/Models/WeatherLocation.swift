//
//  WeatherLocation.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation


struct WeatherLocation: Identifiable, Codable {
    let id: UUID
    var cityName: String
    var region: String?
    var temperature: Int
    var condition: String?
    var highTemp: Int
    var lowTemp: Int
    var time: String?
    var isHomeLocation: Bool
    var lat: Double
    var lon: Double
    var airQuality: Int?
    
    
    
    var geoLocation: GeoLocation {
        return GeoLocation(
            name: self.cityName,
            lat: self.lat,
            lon: self.lon,
            country: "Unknown",
            state: self.region
        )
    }
    
    // Extension for conversion
    func toGeoLocation() -> GeoLocation {
        return GeoLocation(
            name: self.cityName,
            lat: self.lat,
            lon: self.lon,
            country: "",
            state: self.region 
        )
    }
}



// Add CodingKeys if needed
enum CodingKeys: String, CodingKey {
    case id, cityName, region, temperature, condition, highTemp, lowTemp, time, isHomeLocation, lat, lon
}






