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

struct QuestStep {
    var type: StepType
    
    var destination: CLLocationCoordinate2D?
    var radius: CLLocationDistance
    
    var overlayName: String?
}
