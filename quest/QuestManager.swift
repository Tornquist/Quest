//
//  QuestManager.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import CoreLocation

protocol QuestManagerDelegate: class {
    func mainButtonPressed()
    func locationDidChange(to location: CLLocationCoordinate2D)
    func questUpdated(_ quest: QuestProtocol)
    func quit()
    func questComplete() -> Bool
    
    func showDebug(on vc: UIViewController)
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
        if self.currentQuest != nil {
            self.currentQuest.mainButtonPressed()
        } else if self.ableToStartQuest != nil {
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
        
        self.reset()
        self.refreshViews()
    }
    
    func questComplete() -> Bool {
        return self.currentQuest != nil && self.currentQuest.currentStep() == nil
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
                let message = self.currentQuest.successMessage() ?? "You win!"
                self.mainInterface?.showMessage(message)
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
            self.mapInterface?.show(step: step)
        case .compass:
            self.mainInterface?.showMessage("Follow the compass")
            self.mainInterface?.set(viewStyle: .compass)
            self.mapInterface?.clearOverlays()
        case .camera:
            self.mainInterface?.showMessage("Use the camera to find clues")
            self.mainInterface?.set(viewStyle: .camera)
            self.mapInterface?.clearOverlays()
        }
        
        step.complete ? self.mainInterface?.showButton(withTitle: "Continue") : self.mainInterface?.hideButton()
    }
    
    // MARK: - Debug Menus
    
    func showDebug(on vc: UIViewController) {
        let showQuestSelection = self.currentQuest == nil
        
        showQuestSelection ? self.showQuestSelection(on: vc) : self.showStepSelection(on: vc)
    }
    
    func showQuestSelection(on vc: UIViewController) {
        let alert = UIAlertController(title: "Available Quests", message: "Select a quest to begin", preferredStyle: .actionSheet)
        
        self.availableQuests.forEach { (quest) in
            alert.addAction(UIAlertAction(title: quest.name(), style: .default, handler: { (_) in
                self.startQuest(quest)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func showStepSelection(on vc: UIViewController) {
        let alert = UIAlertController(title: "All Quest Steps", message: "Select a new step below to skip or replay", preferredStyle: .actionSheet)
        
        let currentStep = self.currentQuest.currentStep()
        let allSteps = self.currentQuest.allSteps()
        
        for (index, step) in allSteps.enumerated() {
            let isCurrent = currentStep != nil && (step == currentStep!)
            let currentText = isCurrent ? " (current)" : ""
            let name = "\(index): \(step.type.description)\(currentText)"
            
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { (_) in
                self.currentQuest.setStepNumber(to: index)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
