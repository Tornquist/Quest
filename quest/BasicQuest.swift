//
//  BasicQuest.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

class BasicQuest: QuestProtocol {
    
    func startingPosition() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 41.937869, longitude: -87.644062)
    }
    
    func startingRadius() -> CLLocationDistance {
        return 40
    }
}
