//
//  QuestProtocol.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

protocol QuestProtocol: class {
    func name() -> String
    func sku() -> String
    
    func startingPosition() -> CLLocationCoordinate2D
    func startingRadius() -> CLLocationDistance
    
    func canStart() -> Bool
    func locationDidChange(to location: CLLocationCoordinate2D)
    
    func start()
    func currentStep() -> QuestStep?
}
