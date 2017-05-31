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
    
    var manager: QuestManagerDelegate?
    
    var active = false
    var ableToStart = false
    
    init() {
        steps = [
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937869, longitude: -87.644062),
                radius: 60,
                overlayName: nil)
        ]
    }
    
    // MARK: - Quest Protocol
    
    func start(managerDelegate: QuestManagerDelegate) {
        self.step = steps.first
        self.manager = managerDelegate
        self.active = true
    }
    
    func stop() {
        self.step = nil
        self.manager = nil
        self.active = false
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
        return !active && ableToStart
    }
    
    func locationDidChange(to location: CLLocationCoordinate2D) {
        self.active ? self.refreshCurrentStep(with: location) : self.refreshAbleToStart(with: location)
    }
    
    func currentStep() -> QuestStep? {
        return self.step
    }
    
    // MARK: - Internal Methods
    
    func locationFrom(coordinate: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func refreshCurrentStep(with coordinate: CLLocationCoordinate2D) {
        print("Refreshing step")
    }
    
    func refreshAbleToStart(with coordinate: CLLocationCoordinate2D) {
        let userLocation = locationFrom(coordinate: coordinate)
        
        let startingCoords = self.startingPosition()
        let startingLocation = CLLocation(latitude: startingCoords.latitude, longitude: startingCoords.longitude)
        
        let distance = userLocation.distance(from: startingLocation)
        let closeEnough = distance < self.startingRadius()
        
        self.ableToStart = closeEnough
    }
}
