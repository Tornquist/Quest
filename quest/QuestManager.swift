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
    func locationDidChange(to location: CLLocationCoordinate2D)
}

class QuestManager: QuestManagerDelegate {
    
    // Linked Components
    
    weak var mainInterface: MainViewControllerInterface?
    weak var mapInterface: MapViewInterface?
    weak var compassInterface: CompassViewInterface?
    weak var cameraInterface: CameraViewInterface?
    
    // Internal Components
    
    var currentQuest: QuestProtocol?
    
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
    
    // MARK: - Quest Management
    
    func refreshAvailable(with location: CLLocationCoordinate2D) {
        self.availableQuests.forEach({ $0.locationDidChange(to: location) })
        self.mapInterface?.refreshAvailable()
        
        let ableToStart = self.availableQuests.filter { $0.canStart() }
        (ableToStart.count > 0) ? self.showStart(quest: ableToStart[0]) : showFindQuest()
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
