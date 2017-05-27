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

class MainViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var compassView: UIVisualEffectView!
    @IBOutlet weak var compassArrow: UIImageView!
    let locationManager = CLLocationManager()
    var angleToDestination: Double = 0
    var currentHeading: Double = 0
    var currentDestination: CLLocationCoordinate2D!
    
    @IBOutlet weak var centerButtonContainer: UIView!
    @IBOutlet weak var centerButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    var firstMapUpdate = true
    
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
        self.configureMapView()
        self.configureCenterButton()
    }
    
    func configureCenterButton() {
        self.centerButtonContainer.backgroundColor = .clear
        self.centerButtonContainer.layer.cornerRadius = 8
        self.centerButtonContainer.layer.borderWidth = 0.5
        self.centerButtonContainer.layer.borderColor = UIColor.black.cgColor
        self.centerButtonContainer.clipsToBounds = true
    }

    func configureMapView() {
        let topConstraint = NSLayoutConstraint(item: self.mapView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        self.view.addConstraint(topConstraint)
        
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsTraffic = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = true
        self.mapView.isPitchEnabled = false
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(gestureRecognizer:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
        
        self.mapView.delegate = self
    }
    
    func configureIntro() {
        // nothing special yet
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.firstMapUpdate {
            self.centerMap()
            self.firstMapUpdate = false
        }
    }
    
    func didDragMap(gestureRecognizer: UIPanGestureRecognizer) {
        self.centerButton.tintColor = .white
        self.centerButton.isEnabled = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        self.centerMap()
    }
    
    @IBAction func toggleCompassPressed(_ sender: Any) {
        self.compassView.isHidden = !self.compassView.isHidden
    }
    
    func centerMap() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.02
        mapRegion.span.longitudeDelta = 0.02
        
        let mapRect = self.mapRect(region: mapRegion)
        self.mapView.setVisibleMapRect(mapRect, animated: true)
        self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsetsMake(0, 0, self.view.bounds.height/2, 0), animated: true)
        
        self.centerButton.tintColor = .lightGray
        self.centerButton.isEnabled = false
    }
    
    func mapRect(region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + (region.span.latitudeDelta/2.0),
            longitude: region.center.longitude - (region.span.longitudeDelta/2.0)
        )
        
        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - (region.span.latitudeDelta/2.0),
            longitude: region.center.longitude + (region.span.longitudeDelta/2.0)
        )
        
        let topLeftMapPoint = MKMapPointForCoordinate(topLeft)
        let bottomRightMapPoint = MKMapPointForCoordinate(bottomRight)
        
        let origin = MKMapPoint(x: topLeftMapPoint.x,
                                y: topLeftMapPoint.y)
        let size = MKMapSize(width: fabs(bottomRightMapPoint.x - topLeftMapPoint.x),
                             height: fabs(bottomRightMapPoint.y - topLeftMapPoint.y))
        
        return MKMapRect(origin: origin, size: size)
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
