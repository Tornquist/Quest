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

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var compassView: CompassView!
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    enum ViewMode: Int {
        case map = 0
        case compass = 1
        case camera = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureIntro()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.refreshView()
    }
    
    func configureView() {
        self.mapView.visualInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.bounds.height/2, right: 0)
    }
    
    func refreshView() {
        self.display(mode: ViewMode.init(rawValue: self.segmentControl.selectedSegmentIndex) ?? .map)
    }
    
    func display(mode: ViewMode) {
        self.compassView.isHidden = mode != .compass
        self.cameraView.isHidden = mode != .camera
        
        (mode == .compass ? self.compassView.startUpdating() : self.compassView.stopUpdating())
        (mode == .camera ? self.cameraView.startUpdating() : self.cameraView.stopUpdating())
    }
    
    func configureIntro() {
        // nothing special yet
    }
    
    @IBAction func changedSegmentControl(_ sender: UISegmentedControl) {
        self.refreshView()
    }
}
