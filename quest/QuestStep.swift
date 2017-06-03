//
//  QuestStep.swift
//  quest
//
//  Created by Nathan Tornquist on 5/30/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

enum StepType {
    case map
    case compass
    case camera
}

class QuestStep {
    var type: StepType
    
    var destination: CLLocationCoordinate2D!
    var radius: CLLocationDistance!
    
    var overlayName: String?
    
    var complete: Bool = false
    
    init(type: StepType, destination: CLLocationCoordinate2D?, radius: CLLocationDistance?, overlayName: String?) {
        self.type = type
        self.destination = destination
        self.radius = radius
        self.overlayName = overlayName
    }
    
    // Boolean return indicates view refresh needed
    func update(with coordinate: CLLocationCoordinate2D) -> Bool {
        guard (self.type == .map || self.type == .compass) && (self.destination != nil && self.radius != nil) else {
            return false
        }
        
        let distance = LocationHelper.distanceBetween(self.destination, and: coordinate)
        let closeEnough = distance < self.radius
        let updateNeeded = complete != closeEnough
        self.complete = closeEnough
        
        return updateNeeded
    }
    
    func reset() {
        self.complete = false
    }
}
