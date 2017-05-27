//
//  MapView.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewInterface: class {
    func showAvailable(quests: [QuestProtocol])
}

class MapView: UIView, MKMapViewDelegate, UIGestureRecognizerDelegate, MapCenterButtonDelegate, MapViewInterface {
    
    var view: UIView!
    weak var manager: QuestManagerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerButton: MapCenterButton!
    
    @IBOutlet weak var centerButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerButtonRightConstraint: NSLayoutConstraint!
    
    var quests: [QuestProtocol] = []
    
    var firstMapUpdate = true
    
    var visualInsets: UIEdgeInsets = .zero {
        didSet {
            self.centerButtonRightConstraint.constant = 16 + visualInsets.right
            self.centerButtonBottomConstraint.constant = 16 + visualInsets.bottom
        }
    }
    
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
        let nib = UINib(nibName: "MapView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: - View Configuration
    
    func configureTheme() {
        self.backgroundColor = .clear
        self.view.backgroundColor = .clear
        
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsTraffic = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = true
        self.mapView.isPitchEnabled = false
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(gestureRecognizer:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
        
        self.mapView.delegate = self
        
        self.centerButton.delegate = self
    }
    
    // MARK: - Events
    
    func didDragMap(gestureRecognizer: UIPanGestureRecognizer) {
        self.centerButton.allowCenter = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.firstMapUpdate {
            self.centerMap()
            self.firstMapUpdate = false
        }
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        self.centerMap()
    }
    
    // MARK: - MapCenterButtonDelegate
    
    func centerButtonPressed(sender: MapCenterButton) {
        self.centerMap()
    }
    
    // MARK: - Map Positioning
    
    func centerMap() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.01
        mapRegion.span.longitudeDelta = 0.01
        
        let mapRect = self.mapRect(region: mapRegion)
        self.mapView.setVisibleMapRect(mapRect, animated: true)
        self.mapView.setVisibleMapRect(mapRect, edgePadding: self.visualInsets, animated: true)
        
        self.centerButton.allowCenter = false
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
    
    // MARK: - Overlays
    
    func showAvailable(quests: [QuestProtocol]) {
        self.quests = quests
        self.mapView.removeOverlays(self.mapView.overlays)
        
        self.quests.forEach({
            let start = $0.startingPosition()
            let radius = $0.startingRadius()
            self.mapView.add(MKCircle(center: start, radius: radius))
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = .clear
        circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.4)
        return circleRenderer
    }
}
