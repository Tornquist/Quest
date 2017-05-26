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

class MainViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var infoPanel: UIView!
    @IBOutlet weak var infoBackgroundTint: UIView!
    @IBOutlet weak var infoHeader: UIView!
    @IBOutlet weak var infoContent: UIView!
    @IBOutlet weak var infoSeparator: UIView!
    @IBOutlet weak var infoPositionConstraint: NSLayoutConstraint!
    var infoShown = false
    
    var mapView: MKMapView!
    var firstMapUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureIntro()
        self.configureOverlay()
    }
    
    func configureIntro() {
        self.showMapView()
        self.infoShown = false
        self.updateInfoPosition()
        self.updateInfoBackgroundColor()
    }
    
    @IBAction func headerTapped(_ sender: Any) {
        self.infoShown = !self.infoShown
        UIView.animate(withDuration: 0.3, animations: {
            self.updateInfoPosition()
            self.updateInfoBackgroundColor()
            self.view.layoutIfNeeded()
        })
    }
    
    func configureOverlay() {
        self.infoHeader.backgroundColor = .clear
        self.infoSeparator.backgroundColor = .black
        self.infoContent.backgroundColor = .clear
        self.infoBackgroundTint.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 242.0/255.0, alpha: 0.3)
        
        let corners = UIRectCorner.topLeft.union(UIRectCorner.topRight)
        let radius = 16
        
        let maskPath = UIBezierPath(roundedRect: self.infoPanel.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.infoPanel.bounds;
        maskLayer.path = maskPath.cgPath;
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.infoPanel.bounds;
        borderLayer.path = maskPath.cgPath;
        borderLayer.lineWidth = 0.5
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        self.infoPanel.layer.mask = maskLayer;
        self.infoPanel.layer.masksToBounds = true
        self.infoPanel.layer.addSublayer(borderLayer)
    }
    
    func updateInfoPosition() {
        self.infoPositionConstraint.constant = self.infoShown ? self.view.frame.height : 0
    }
    
    func updateInfoBackgroundColor() {
        self.infoBackgroundTint.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 242.0/255.0, alpha: self.infoShown ? 0.6 : 0.3)
    }
    
    func setContainerTo(contentView: UIView) {
        self.containerView.subviews.forEach({ $0.removeFromSuperview() })
        
        let width = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: self.containerView, attribute: .width, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: self.containerView, attribute: .height, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self.containerView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self.containerView, attribute: .centerY, multiplier: 1, constant: 0)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(contentView)
        
        self.containerView.addConstraints([width, height, centerX, centerY])
    }
    
    func showMapView() {
        if mapView == nil {
            self.mapView = MKMapView()
            self.mapView.showsPointsOfInterest = false
            self.mapView.showsTraffic = false
            self.mapView.showsBuildings = false
            self.mapView.showsUserLocation = true
            
            self.mapView.delegate = self
        }
        
        self.setContainerTo(contentView: self.mapView)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.firstMapUpdate {
            self.centerMap()
            self.firstMapUpdate = false
        }
    }
    
    func centerMap() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.02
        mapRegion.span.longitudeDelta = 0.02
        
        self.mapView.setRegion(mapRegion, animated: true)
    }
}
