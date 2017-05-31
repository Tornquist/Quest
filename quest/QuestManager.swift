//
//  QuestManager.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

protocol QuestManagerDelegate: class {
    func mainButtonPressed()
    func locationDidChange(to location: CLLocationCoordinate2D)
    func questUpdated(_ quest: QuestProtocol)
    func quit()
}

class QuestManager: QuestManagerDelegate {
    
    // Linked Components
    
    weak var mainInterface: MainViewControllerInterface?
    weak var mapInterface: MapViewInterface?
    weak var compassInterface: CompassViewInterface?
    weak var cameraInterface: CameraViewInterface?
    
    // Internal Components
    
    var currentQuest: QuestProtocol!
    var ableToStartQuest: QuestProtocol!
    
    var availableQuests: [QuestProtocol] = []
    
    func loadQuests() {
        // Fancy file IO... or just a single named class
        self.availableQuests = [BasicQuest()]
    }
    
    func reset() {
        self.currentQuest = nil
        self.mainInterface?.set(viewStyle: .map)
        self.mapInterface?.showAvailable(quests: self.availableQuests)
        
        self.showFindQuest()
    }
    
    // MARK: - QuestManagerDelegate
    
    func locationDidChange(to location: CLLocationCoordinate2D) {
        if self.currentQuest == nil {
            self.refreshAvailable(with: location)
        } else {
            self.currentQuest.locationDidChange(to: location)
        }
    }
    
    func mainButtonPressed() {
        if self.currentQuest == nil && self.ableToStartQuest != nil {
            self.startQuest(self.ableToStartQuest)
        }
    }
    
    func questUpdated(_ quest: QuestProtocol) {
        guard self.currentQuest != nil && self.currentQuest.sku() == quest.sku() else {
            // Wrong Quest
            quest.stop()
            return
        }
        
        self.refreshViews()
    }
    
    func quit() {
        self.currentQuest?.stop()
        self.currentQuest = nil
        self.refreshViews()
    }
    
    // MARK: - Quest Management
    
    func startQuest(_ quest: QuestProtocol) {
        self.currentQuest = quest
        self.ableToStartQuest = nil
        
        self.currentQuest.start(managerDelegate: self)
        self.refreshViews()
    }
    
    func refreshAvailable(with location: CLLocationCoordinate2D) {
        self.availableQuests.forEach({ $0.locationDidChange(to: location) })
        self.mapInterface?.refreshAvailable()
        
        let ableToStart = self.availableQuests.filter { $0.canStart() }
        self.ableToStartQuest = (ableToStart.count > 0) ? ableToStart[0] : nil
        
        self.refreshViews()
    }
    
    func refreshViews() {
        if self.currentQuest != nil {
            self.mainInterface?.quitButton(show: true)
            let step = self.currentQuest.currentStep()
            
            guard step != nil else {
                self.mainInterface?.showMessage("You win!")
                self.mainInterface?.hideButton()
                return
            }

            self.show(step: step!)
        } else if self.ableToStartQuest != nil {
            self.mainInterface?.set(viewStyle: .map)
            self.mainInterface?.quitButton(show: false)
            self.showStart(quest: self.ableToStartQuest)
        } else {
            self.mainInterface?.quitButton(show: false)
            self.mainInterface?.set(viewStyle: .map)
            self.showFindQuest()
        }
    }
    
    func showFindQuest() {
        self.mainInterface?.showMessage("Walk to a quest marker to begin")
        self.mainInterface?.hideButton()
    }
    
    func showStart(quest: QuestProtocol) {
        self.mainInterface?.showMessage("Would you like to begin \"\(quest.name())\"?")
        self.mainInterface?.showButton(withTitle: "START QUEST")
    }
    
    func show(step: QuestStep) {
        switch step.type {
        case .map:
            self.mainInterface?.showMessage("Go to the location on the map")
            self.mainInterface?.set(viewStyle: .map)
            self.mainInterface?.hideButton()
        case .compass:
            self.mainInterface?.showMessage("Follow the compass")
            self.mainInterface?.set(viewStyle: .compass)
            self.mainInterface?.hideButton()
        case .camera:
            self.mainInterface?.showMessage("Use the camera to find clues")
            self.mainInterface?.set(viewStyle: .camera)
            self.mainInterface?.hideButton()
        }
    }
}
