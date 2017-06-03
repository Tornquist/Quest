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
    
    var complete = false
    
    init() {
        complete = false
        
        steps = [
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .map,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .map,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .map,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
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
        self.steps.forEach({ $0.reset() })
        
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
    
    func mainButtonPressed() {
        let currentStep: QuestStep! = self.currentStep()
        
        guard currentStep != nil && currentStep.complete else {
            return
        }
        
        if let index = self.steps.index(where: { $0 == currentStep! }) {
            if index < self.steps.count - 1 {
                self.step = self.steps[index + 1]
                self.manager?.questUpdated(self)
            } else {
                print("On last item already")
            }
        }
    }
    
    // MARK: - Internal Methods
    
    func refreshCurrentStep(with coordinate: CLLocationCoordinate2D) {
        let refreshNeeded = self.currentStep()?.update(with: coordinate) ?? false
        
        if refreshNeeded {
            self.manager?.questUpdated(self)
        }
    }
    
    func refreshAbleToStart(with coordinate: CLLocationCoordinate2D) {
        let distance = LocationHelper.distanceBetween(self.startingPosition(), and: coordinate)
        let closeEnough = distance < self.startingRadius()
        
        self.ableToStart = closeEnough
    }
}
