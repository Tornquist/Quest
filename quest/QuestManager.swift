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
    }
    
    // MARK: - QuestManagerDelegate
    
    func locationDidChange(to location: CLLocationCoordinate2D) {
        print("new location: \(location)")
    }
}
