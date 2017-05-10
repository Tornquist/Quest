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
    
    var currentDestination: CLLocationCoordinate2D!
    
    @IBOutlet weak var directionSwitch: UISwitch!
    
    var angleToDestination: Double = 0
    var currentHeading: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The Bagel
        let lat: Double = 41.937869
        let long: Double = -87.644062
        self.currentDestination = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestLocationAccess()
    }

    func requestLocationAccess() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
        
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            self.angleToDestination = self.getBearing(from: locations[0].coordinate, to: self.currentDestination)
            self.updateLine()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // No action
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        self.accuracyLabel.text = "Accuracy: \(newHeading.headingAccuracy)"
        
        self.currentHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.updateLine()
    }
    
    func updateLine() {
        self.angleLabel.text = "∠ North: \(self.currentHeading)\n∠ Destination: \(self.angleToDestination)"

        
        var radians = degreesToRadians(self.currentHeading)
        if self.directionSwitch.isOn {
            var tempAngle = (self.currentHeading - self.angleToDestination)
            if tempAngle < 0 { tempAngle += 360 }
            if tempAngle > 360 { tempAngle -= 360}
            radians = degreesToRadians(tempAngle)
        }
        
        self.rotateLineTo(-radians)
    }
    
    func rotateLineTo(_ radians: Double) {
        lineView.transform = CGAffineTransform.identity
        lineView.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
    }
    
    func getBearing(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = degreesToRadians(source.latitude)
        let lon1 = degreesToRadians(source.longitude)
        
        let lat2 = degreesToRadians(destination.latitude);
        let lon2 = degreesToRadians(destination.longitude);
        
        let dLon = lon1 - lon2;
        
        let y = sin(dLon) * cos(lat1);
        let x = cos(lat2) * sin(lat1) - sin(lat2) * cos(lat1) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        var degrees = radiansToDegrees(radiansBearing)
        degrees -= 90 // Rotate 0 to north
        if (degrees < 0) { degrees += 360 }
        
        // Mirror
        degrees = -1 * (degrees - 360)
        
        return degrees
    }
    
    func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
    
    @IBAction func switchToggled(_ sender: Any) {
        self.updateLine()
    }
}

