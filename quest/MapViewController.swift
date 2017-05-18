//
//  MapViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/18/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsTraffic = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = true
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.02
        mapRegion.span.longitudeDelta = 0.02
        
        self.mapView.setRegion(mapRegion, animated: true)
    }
}
