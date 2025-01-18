//
//  TouristAttraction.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation

struct TouristAttraction: Identifiable ,Codable{
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}
