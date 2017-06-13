//
//  QuestStep.swift
//  quest
//
//  Created by Nathan Tornquist on 5/30/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

enum StepType: String, CustomStringConvertible {
    case map = "map"
    case compass = "compass"
    case camera = "camera"
    
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
    
    var autocomplete: Bool = false
    
    var destination: CLLocationCoordinate2D!
    var radius: CLLocationDistance!
    
    var overlayName: String?
    
    var question: String?
    var questionType: QuestionType?
    var answer: String?
    var answers: [String] = []
    
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
    
    convenience init(type: StepType, destination: CLLocationCoordinate2D?, radius: CLLocationDistance?, overlayName: String?, question: String, answer: String, options: [String]) {
        self.init(type: type, destination: destination, radius: radius, overlayName: overlayName, question: question, answer: answer)
        
        self.answers = options
        self.questionType = options.isEmpty ? .freeResponse : .multipleChoice
    }
    
    convenience init(type: StepType, overlayName: String?, question: String, answer: String) {
        self.init(type: type, destination: nil, radius: nil, overlayName: overlayName, question: question, answer: answer)
    }
    
    convenience init(type: StepType, overlayName: String?, question: String, answer: String, options: [String]) {
        self.init(type: type, destination: nil, radius: nil, overlayName: overlayName, question: question, answer: answer)
        
        self.answers = options
        self.questionType = .multipleChoice
    }
    
    convenience init?(withJSON jsonDictionary: [String: AnyObject]) {
        let typeString = jsonDictionary["type"] as? String
        let type = StepType(rawValue: typeString ?? "")
        guard type != nil else { return nil }
        
        var destinationPosition: CLLocationCoordinate2D? = nil
        var destinationRadius: CLLocationDistance? = nil
        var autocomplete: Bool = false
        
        if let destinationDict = jsonDictionary["destination"] as? [String: AnyObject] {
            let lat = destinationDict["lat"] as? Double
            let long = destinationDict["long"] as? Double
            let radius = destinationDict["radius"] as? Double
            autocomplete = destinationDict["autocomplete"] as? Bool ?? false
            
            guard lat != nil && long != nil && radius != nil else {
                return nil
            }
            
            destinationPosition = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            destinationRadius = radius!
        }
        
        let overlayName = jsonDictionary["overlay"] as? String
        
        var question: String? = nil
        var answer: String? = nil
        var options: [String] = []
        
        if let questionDict = jsonDictionary["question"] as? [String: AnyObject] {
            question = questionDict["question"] as? String
            answer = questionDict["answer"] as? String
            options = questionDict["options"] as? [String] ?? []
            
            guard question != nil && answer != nil else {
                return nil
            }
        }
        
        if question == nil {
            self.init(type: type!, destination: destinationPosition, radius: destinationRadius, overlayName: overlayName)
        } else {
            self.init(type: type!, destination: destinationPosition, radius: destinationRadius, overlayName: overlayName, question: question!, answer: answer!, options: options)
        }
        
        self.autocomplete = autocomplete
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
        
        if (self.state == .complete && self.autocomplete) {
            self.parent?.stepCompleted(self)
            return false // No need to trigger update twice
        }
        
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
