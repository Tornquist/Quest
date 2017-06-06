//
//  QuestStep.swift
//  quest
//
//  Created by Nathan Tornquist on 5/30/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

enum StepType: CustomStringConvertible {
    case map
    case compass
    case camera
    
    var description: String {
        switch self {
        case .map:
            return "Map"
        case .compass:
            return "Compass"
        case .camera:
            return "Camera"
        }
    }
}

enum QuestState {
    case ready
    case question
    case complete
}

enum QuestionType {
    case freeResponse
    case multipleChoice
}

class QuestStep {
    var id: String
    
    var type: StepType
    
    var destination: CLLocationCoordinate2D!
    var radius: CLLocationDistance!
    
    var overlayName: String?
    
    var question: String?
    var questionType: QuestionType?
    var answer: String?
    
    var userAnswer: String? {
        didSet {
            self.refreshState()
            self.parent?.stepQuestionAnswered(self)
        }
    }
    
    var closeEnough: Bool = false
    var userAnswerCorrect: Bool {
        get {
            return self.question == nil || (self.userAnswer != nil && self.userAnswer!.lowercased() == self.answer!.lowercased())
        }
    }
    
    var state: QuestState = .ready
    
    weak var parent: QuestProtocol?
    
    init(type: StepType, destination: CLLocationCoordinate2D?, radius: CLLocationDistance?, overlayName: String?) {
        self.id = UUID.init().uuidString
        
        self.type = type
        self.destination = destination
        self.radius = radius
        self.overlayName = overlayName
    }
    
    convenience init(type: StepType, destination: CLLocationCoordinate2D?, radius: CLLocationDistance?, overlayName: String?, question: String, answer: String) {
        self.init(type: type, destination: destination, radius: radius, overlayName: overlayName)
        
        self.question = question
        self.questionType = .freeResponse
        self.answer = answer
    }
    
    convenience init(type: StepType, overlayName: String?, question: String, answer: String) {
        self.init(type: type, destination: nil, radius: nil, overlayName: overlayName, question: question, answer: answer)
    }
    
    // Boolean return indicates view refresh needed
    func update(with coordinate: CLLocationCoordinate2D) -> Bool {
        guard (self.type == .map || self.type == .compass) && (self.destination != nil && self.radius != nil) else {
            if !self.closeEnough {
                self.closeEnough = true
                self.refreshState()
                return true
            }
            
            return false
        }
        
        let distance = LocationHelper.distanceBetween(self.destination, and: coordinate)
        let closeEnough = distance < self.radius
        let updateNeeded = self.closeEnough != closeEnough
        self.closeEnough = closeEnough
        
        self.refreshState()
        
        return updateNeeded
    }
    
    func mark(asComplete complete: Bool) {
        if complete {
            if question != nil { self.userAnswer = self.answer }
            self.closeEnough = true
            self.refreshState()
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.closeEnough = false
        self.userAnswer = nil
        self.state = .ready
    }
    
    static func ==(lhs: QuestStep, rhs: QuestStep) -> Bool {
        return lhs.id == rhs.id
    }
    
    func refreshState() {
        self.state = self.closeEnough == false ? .ready : (self.userAnswerCorrect ? .complete : .question)
    }
}
