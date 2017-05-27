//
//  MainViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/17/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum MainViewStyle: Int {
    case map = 0
    case compass = 1
    case camera = 2
}

protocol MainViewControllerInterface: class {
    func set(viewStyle: MainViewStyle)
}

class MainViewController: UIViewController, CLLocationManagerDelegate, MainViewControllerInterface {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var compassView: CompassView!
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var questManager: QuestManager!
    
    var viewStyle: MainViewStyle = .map
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureQuestManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshView()
        
        // Compass view is current location/GPS manager
        // as well as a normal view component
        self.compassView.startUpdating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.refreshView()
        self.compassView.stopUpdating()
    }
    
    // MARK: - View Management
    
    func configureView() {
        self.mapView.visualInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.bounds.height/2, right: 0)
    }
    
    func refreshView() {
        self.display(mode: self.viewStyle)
    }
    
    func display(mode: MainViewStyle) {
        self.compassView.isHidden = mode != .compass
        self.cameraView.isHidden = mode != .camera
        
        (mode == .camera ? self.cameraView.startUpdating() : self.cameraView.stopUpdating())
    }
    
    @IBAction func changedSegmentControl(_ sender: UISegmentedControl) {
        self.viewStyle = MainViewStyle.init(rawValue: sender.selectedSegmentIndex) ?? .map
        self.refreshView()
    }
    
    // MARK: - Quest Managment
    
    func configureQuestManager() {
        self.questManager = QuestManager()
        
        self.questManager.mainInterface = self
        self.questManager.mapInterface = self.mapView
        self.questManager.compassInterface = self.compassView
        self.questManager.cameraInterface = self.cameraView
        
        self.mapView.manager = self.questManager
        self.compassView.manager = self.questManager
        self.cameraView.manager = self.questManager
        
        self.questManager.loadQuests()
        self.questManager.reset()
    }
    
    // MARK: - Public Interface
    
    func set(viewStyle: MainViewStyle) {
        self.viewStyle = viewStyle
        self.refreshView()
    }
}
