//
//  GeoLocation.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation


struct GeoLocation: Codable,Identifiable,Equatable {
    let id = UUID() 
    let name:String
    //let localName:LocalNames
    let lat:Double
    let lon:Double
    let country:String
    let state:String?
    
    enum CodingKeys: String, CodingKey {
        case name,lat,lon,country,state
       // case localName = "local_names"
    }
    
    // Add Equatable conformance by implementing the == operator
        static func == (lhs: GeoLocation, rhs: GeoLocation) -> Bool {
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.lat == rhs.lat &&
            lhs.lon == rhs.lon &&
            lhs.country == rhs.country &&
            lhs.state == rhs.state
        }

}

