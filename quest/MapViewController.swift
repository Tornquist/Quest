//
//  MapViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/18/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var firstUpdate = true
    
    var _pondOverlay: MKPolygon!
    var pondOverlay: MKPolygon {
        get {
            if _pondOverlay == nil {
                self._pondOverlay = self.getOverlay()
            }
            return _pondOverlay
        }
    }
    var overlayShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsTraffic = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
        
        let toggleShadeButton = UIBarButtonItem(title: "Shade", style: .plain, target: self, action: #selector(toggleShade(_:)))
        self.navigationItem.rightBarButtonItem = toggleShadeButton
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.02
        mapRegion.span.longitudeDelta = 0.02
        
        self.mapView.setRegion(mapRegion, animated: true)
    }
    
    func toggleShade(_ sender: UIBarButtonItem) {
        self.overlayShown = !self.overlayShown
        if self.overlayShown && !self.mapView.overlays.contains(where: { ($0 as? MKPolygon) == self.pondOverlay }){
            self.mapView.add(self.pondOverlay)
        } else if !self.overlayShown {
            self.mapView.remove(self.pondOverlay)
        }
    }
    
    // MARK: MK Map View Delegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.firstUpdate {
            self.centerButtonPressed(self)
            self.firstUpdate = false
        }
    }
    
    func getShadePoints() -> [CLLocationCoordinate2D] {
        let latLongs: [(lat: CGFloat, long: CGFloat)] = [
            (lat: 41.932778, long: -87.639291),
            (lat: 41.925634, long: -87.639061),
            (lat: 41.925712, long: -87.636118),
            (lat: 41.925853, long: -87.636204),
            (lat: 41.925901, long: -87.636301),
            (lat: 41.925915, long: -87.636405),
            (lat: 41.925951, long: -87.636596),
            (lat: 41.926049, long: -87.63685),
            (lat: 41.926512, long: -87.637685),
            (lat: 41.926881, long: -87.638167),
            (lat: 41.92721, long: -87.638487),
            (lat: 41.927394, long: -87.638613),
            (lat: 41.927751, long: -87.6388),
            (lat: 41.928005, long: -87.638878),
            (lat: 41.928707, long: -87.638908),
            (lat: 41.929561, long: -87.638795),
            (lat: 41.930369, long: -87.63883),
            (lat: 41.930712, long: -87.638892),
            (lat: 41.931305, long: -87.639031),
            (lat: 41.93175, long: -87.639045),
            (lat: 41.93197, long: -87.638977),
            (lat: 41.932195, long: -87.638798),
            (lat: 41.932303, long: -87.638768),
            (lat: 41.932377, long: -87.638902)
        ]
        
        return latLongs.map({ CLLocationCoordinate2D(latitude: CLLocationDegrees($0.lat), longitude: CLLocationDegrees($0.long)) })
    }
    
    func getOverlay() -> MKPolygon {
        let coords = getShadePoints()
        return MKPolygon(coordinates: coords, count: coords.count)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay as? MKPolygon) == self.pondOverlay {
            let renderer = MKPolygonRenderer(polygon: self.pondOverlay)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
            return renderer
        }
        else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
