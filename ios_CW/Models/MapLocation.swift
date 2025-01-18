//
//  MapLocation.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation
import MapKit

struct MapLocation: Identifiable, Codable {
    let id: UUID
    let title: String?
    let latitude: Double
    let longitude: Double
    
    init(annotation: MKPointAnnotation) {
        self.id = UUID()
        self.title = annotation.title
        self.latitude = annotation.coordinate.latitude
        self.longitude = annotation.coordinate.longitude
    }
    
    init(title: String?, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // To recreate an MKPointAnnotation from MapLocation
    func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return annotation
    }
}
