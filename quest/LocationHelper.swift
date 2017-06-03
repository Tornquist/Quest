//
//  LocationHelper.swift
//  quest
//
//  Created by Nathan Tornquist on 6/3/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper {
    static func locationFrom(coordinate: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    static func distanceBetween(_ coord1: CLLocationCoordinate2D, and coord2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = LocationHelper.locationFrom(coordinate: coord1)
        let location2 = LocationHelper.locationFrom(coordinate: coord2)
        
        return location1.distance(from: location2)
    }
}
