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
        }
    }
    
    func mainButtonPressed() {
        if self.currentQuest == nil && self.ableToStartQuest != nil {
            self.startQuest(self.ableToStartQuest)
        }
    }
    
    // MARK: - Quest Management
    
    func startQuest(_ quest: QuestProtocol) {
        self.currentQuest = quest
        self.ableToStartQuest = nil
        
        self.currentQuest.start()
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
            self.mainInterface?.showMessage("Active Quest: \(self.currentQuest.name())")
            self.mainInterface?.hideButton()
        } else if self.ableToStartQuest != nil {
            self.showStart(quest: self.ableToStartQuest)
        } else {
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
}
