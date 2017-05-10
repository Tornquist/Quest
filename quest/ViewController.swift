//
//  ViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/8/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestLocationAccess()
    }

    func requestLocationAccess() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // 3
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 5
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        self.accuracyLabel.text = "Accuracy: \(newHeading.headingAccuracy)"
        
        let degrees = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        let radians = degrees * Double.pi / 180
        
        self.angleLabel.text = "Degrees: \(degrees)\nRadians: \(radians)"
        self.rotateLineTo(-radians)
    }
    
    func rotateLineTo(_ radians: Double) {
        lineView.transform = CGAffineTransform.identity
        lineView.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
    }
}

