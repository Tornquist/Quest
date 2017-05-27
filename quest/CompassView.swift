//
//  CompassView.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import CoreLocation

protocol CompassViewInterface: class {
    
}

class CompassView: UIView, CLLocationManagerDelegate, CompassViewInterface {
    
    var view: UIView!
    weak var manager: QuestManagerDelegate?
    
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    @IBOutlet weak var arrow: UIImageView!
    let locationManager = CLLocationManager()
    var angleToDestination: Double = 0
    var currentHeading: Double = 0
    var currentDestination: CLLocationCoordinate2D!
    
    var locationRequested = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureNib()
        self.configureTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard self.subviews.count == 0 else {
            return
        }
        
        self.configureNib()
        self.configureTheme()
    }
    
    func configureNib() {
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.addSubview(self.view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "CompassView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: - View Configuration
    
    func configureTheme() {
        self.backgroundColor = .clear
        self.view.backgroundColor = .clear
    }
    
    // MARK: - Exernal Managment
    
    func requestLocation() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationRequested = true
    }
    
    func startUpdating() {
        if !self.locationRequested {
            self.requestLocation()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.headingFilter = 1
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func stopUpdating() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
    }
    
    func set(destination: CLLocationCoordinate2D) {
        self.currentDestination = destination
    }
    
    // MARK: - Compass
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 else {
            return
        }
        
        self.manager?.locationDidChange(to: locations[0].coordinate)
        
        if self.currentDestination != nil {
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
        guard self.arrow != nil else { return }
        
        self.arrow.transform = CGAffineTransform.identity
        self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
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
