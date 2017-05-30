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
    
    var step: QuestStep?
    var steps: [QuestStep] = []
    
    init() {
        steps = [
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937869, longitude: -87.644062),
                radius: 60,
                overlayName: nil)
        ]
    }
    

    var ableToStart = false
    
    func start() {
        self.step = steps.first
    }
    
    func name() -> String {
        return "Basic Quest"
    }
    
    func sku() -> String {
        return "basic_quest"
    }
    
    func startingPosition() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386)
    }
    
    func startingRadius() -> CLLocationDistance {
        return 60
    }
    
    func canStart() -> Bool {
        return ableToStart
    }
    
    func locationDidChange(to location: CLLocationCoordinate2D) {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let startingCoords = self.startingPosition()
        let startingLocation = CLLocation(latitude: startingCoords.latitude, longitude: startingCoords.longitude)
        
        let distance = userLocation.distance(from: startingLocation)
        let closeEnough = distance < self.startingRadius()
        
        self.ableToStart = closeEnough
    }
    
    func currentStep() -> QuestStep? {
        return self.step
    }
}
