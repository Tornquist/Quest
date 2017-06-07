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
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .map,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil,
                question: "What does the r in rgb stand for?",
                answer: "Red"),
            QuestStep(
                type: .camera,
                overlayName: "river",
                question: "What does the b in rgb stand for?",
                answer: "Blue"),
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .map,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 120,
                overlayName: nil),
            QuestStep(
                type: .compass,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 60,
                overlayName: nil),
            QuestStep(
                type: .map,
                destination: CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
                radius: 180,
                overlayName: nil)
        ]
        
        for step in steps {
            step.parent = self
        }
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
    
    func successMessage() -> String? {
        return nil
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
        guard currentStep != nil else { return }
        
        switch currentStep.state {
        case .question:
            self.manager?.askQuestionFor(step: currentStep)
            break
        case .complete:
            self.incrementIfPossible()
            break
        default:
            break
        }
    }
    
    func allSteps() -> [QuestStep] {
        return self.steps
    }
    
    func setStepNumber(to stepIndex: Int) {
        let validNumber = stepIndex > 0 && stepIndex < self.steps.count
        let differentStep = self.currentStepIndex() != stepIndex
        
        guard validNumber && differentStep else {
            return
        }
        
        self.step = self.steps[stepIndex]
        
        for (index, step) in self.steps.enumerated() {
            step.mark(asComplete: index < stepIndex)
        }
        
        self.manager?.questUpdated(self)
    }
    
    func stepQuestionAnswered(_ step: QuestStep) {
        let currentStep = self.currentStep()
        guard currentStep != nil && currentStep! == step && step.state == .complete else {
            return
        }
        
        self.incrementIfPossible()
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
    
    func incrementIfPossible() {
        let index: Int! = self.currentStepIndex()
        guard index != nil else {
            return
        }
        
        self.step = (index < self.steps.count - 1) ? self.steps[index + 1] : nil
        self.manager?.questUpdated(self)
    }
    
    func currentStepIndex() -> Int? {
        let currentStep: QuestStep! = self.currentStep()
        
        guard currentStep != nil else {
            return nil
        }
        
        return self.steps.index(where: { $0 == currentStep! })
    }
}
