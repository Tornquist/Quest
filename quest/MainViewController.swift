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
    
    @IBOutlet weak var compassView: UIVisualEffectView!
    @IBOutlet weak var compassArrow: UIImageView!
    let locationManager = CLLocationManager()
    var angleToDestination: Double = 0
    var currentHeading: Double = 0
    var currentDestination: CLLocationCoordinate2D!
    
    @IBOutlet weak var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureIntro()
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
            locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
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
    
    // MARK: - Compass
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 && self.currentDestination != nil {
            self.angleToDestination = self.getBearing(from: locations[0].coordinate, to: self.currentDestination)
            self.updateArrow()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // No action
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        
        self.currentHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.updateArrow()
    }
    
    func updateArrow() {
        var degrees = -self.currentHeading
        
        if self.currentDestination != nil {
            degrees = (self.angleToDestination - self.currentHeading)
        }
        
        while (degrees < 0) { degrees += 360 }
        while (degrees > 360) { degrees -= 360 }
        let radians = degreesToRadians(degrees)
        
        self.rotateArrowTo(radians)
    }
    
    func rotateArrowTo(_ radians: Double) {
        self.compassArrow.transform = CGAffineTransform.identity
        self.compassArrow.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
    }
    
    func getBearing(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = degreesToRadians(destination.latitude)
        let lon1 = degreesToRadians(destination.longitude)
        
        let lat2 = degreesToRadians(source.latitude);
        let lon2 = degreesToRadians(source.longitude);
        
        let dLon = lon1 - lon2;
        
        let y = sin(dLon) * cos(lat1);
        let x = cos(lat2) * sin(lat1) - sin(lat2) * cos(lat1) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        var degrees = radiansToDegrees(radiansBearing)
        
        if degrees < 0 { degrees += 360 }
        if degrees > 360 {degrees -= 360 }
        
        return degrees
    }
    
    func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
}
