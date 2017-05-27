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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureIntro()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.compassView.requestLocation()
        self.compassView.startUpdating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.compassView.stopUpdating()
    }
    
    func configureView() {
        self.mapView.visualInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.bounds.height/2, right: 0)
    }
    
    func configureIntro() {
        // nothing special yet
    }
    
    @IBAction func toggleCompassPressed(_ sender: Any) {
        self.compassView.isHidden = !self.compassView.isHidden
    }
}
