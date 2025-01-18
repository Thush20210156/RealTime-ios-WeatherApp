//
//  WeatherResponse.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation

struct WeatherResponse: Codable {
    
    let lat:Double
    let lon:Double
    let timezone:String?
    let timezoneOffset:Int?
    let current:Current
    let minutely:[Minutely]?
    let hourly:[Hourly]?
    let daily:[Daily]?
    let alerts: [Alert]?
    
    enum codingKeys: String, CodingKey {
        case lat, lon, timezone , alerts
        case timezoneOffset = "timezone_offset"
        case current ,minutely , hourly , daily
        
    }
    
}

struct Current: Codable {
    let dt:Int?
    let sunrise:Int?
    let sunset:Int?
    let temp:Double
    let feelsLike:Double
    let pressure:Int
    let humidity:Int
    let dewPoint:Double
    let uvi:Double
    let clouds:Int
    let windSpeed:Double
    let windDeg:Int
    let weather:[Weather]
    let rain:Rain?
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp,  pressure, humidity,uvi , clouds, weather, rain
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
       
        
    }
}

struct Weather : Codable {
    let id:Int
    let main:String
    let description:String
    let icon:String
}

struct Rain: Codable {
    let oneHour:Double
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

struct Minutely: Codable {
    let dt:Int
    let precipitation:Double
}

struct Hourly: Codable {
    let dt:Int
    let temp:Double
    let feelsLike:Double
    let pressure:Int
    let humidity:Int
    let dewPoint:Double
    let uvi:Double
    let clouds:Int
    let visibility:Int?
    let windSpeed:Double
    let windDeg:Int
    let windGust:Double?
    let weather:[Weather]
    let rain:Rain?
    
    enum CodingKeys: String, CodingKey {
        case dt, temp, pressure, humidity, uvi, clouds, visibility, rain,weather
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        
    }
}

struct Daily: Codable {
    
    var id: Int {
            return dt  
        }
    
    let dt:Int
    let sunrise:Int
    let sunset:Int
    let moonrise:Int
    let moonset:Int
    let moonPhase:Double
    let summary:String
    let temp:Temp
    let feelsLike:FeelLike
    let pressure:Int
    let humidity:Int
    let dewPoint:Double
    let windSpeed:Double
    let windDeg:Int
    let windGust:Double?
    let weather:[Weather]
    let clouds:Int
    let pop:Double?
    let rain:Double?
    let snow:Double?
    let uvi:Double
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise, moonset, weather, clouds, pop, rain,snow, uvi, summary, temp, pressure, humidity
        case moonPhase = "moon_phase"
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
   
}

struct Temp: Codable {
    let day:Double
    let min:Double
    let max:Double
    let night:Double
    let eve:Double
    let morn:Double
}

struct FeelLike: Codable {
   let day:Double
   let night:Double
   let eve:Double
   let morn:Double
}



struct Alert: Codable {
   let senderName:String
   let event:String
   let start:Int
   let end:Int
   let description:String
   let tags:[String]
    

    enum CodingKeys: String, CodingKey {
        case senderName = "sender_name"
        case event, start, end, description, tags
    }
}

