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
    func clearOverlays()
    func showAvailable(quests: [QuestProtocol])
    func show(step questStep: QuestStep)
    func refreshAvailable()
}

class MapView: UIView, MKMapViewDelegate, UIGestureRecognizerDelegate, MapCenterButtonDelegate, MapViewInterface {
    
    var view: UIView!
    weak var manager: QuestManagerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerButton: MapCenterButton!
    
    @IBOutlet weak var centerButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerButtonRightConstraint: NSLayoutConstraint!
    
    var quests: [QuestProtocol] = []
    var questOverlays: [MKCircle] = []
    var canStartQuest: [Bool] = []
    
    weak var questStep: QuestStep?
    var questStepOverlay: MKCircle?
    var questStepComplete: Bool?
    
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
    
    func clearOverlays() {
        self.quests = []
        self.questOverlays.removeAll()
        self.canStartQuest.removeAll()
        
        self.questStep = nil
        self.questStepOverlay = nil
        self.questStepComplete = nil
        
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    func show(step questStep: QuestStep) {
        let newStep = self.questStep == nil || self.questStep?.id != questStep.id
        let completeChanged = self.questStepComplete != questStep.complete
        
        if newStep {
            self.clearOverlays()
            self.questStep = questStep
        }
        
        if newStep || completeChanged {
            if self.questStepOverlay != nil {
                self.mapView.remove(self.questStepOverlay!)
            }
            
            self.questStepOverlay = self.overlayFor(questStep: questStep)
            self.questStepComplete = questStep.complete
            
            if self.questStepOverlay != nil {
                self.mapView.add(self.questStepOverlay!)
            }
        }
    }
    
    func showAvailable(quests: [QuestProtocol]) {
        self.clearOverlays()
        
        self.quests = quests
        
        self.quests.forEach { (quest) in
            let circle = overlayFor(quest: quest)
            
            self.canStartQuest.append(quest.canStart())
            self.questOverlays.append(circle)
            
            self.mapView.add(circle)
        }
    }
    
    func refreshAvailable() {
        for (index, quest) in self.quests.enumerated() {
            let canStart = quest.canStart()
            let needsUpdate = canStart != self.canStartQuest[index]
            self.canStartQuest[index] = canStart
            
            guard !needsUpdate else { return }
            
            let circle = overlayFor(quest: quest)
            
            let overlay = self.questOverlays[index]
            self.mapView.remove(overlay)
            self.mapView.add(circle)
            
            self.questOverlays[index] = circle
        }
    }
    
    func overlayFor(quest: QuestProtocol) -> MKCircle {
        let start = quest.startingPosition()
        let radius = quest.startingRadius()
        let circle = MKCircle(center: start, radius: radius)
        circle.title = quest.sku()
        
        return circle
    }
    
    func overlayFor(questStep: QuestStep) -> MKCircle? {
        guard questStep.destination != nil && questStep.radius != nil else {
            return nil
        }
        
        let circle = MKCircle(center: questStep.destination!, radius: questStep.radius!)
        circle.title = questStep.id
        
        return circle
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let title = (overlay.title ?? "") ?? ""
        let index = self.quests.index { (quest) -> Bool in
            return title == quest.sku()
        }
        let isQuest = index != nil
        let isQuestStep = title == self.questStep?.id
        
        var canStart = false
        
        if isQuest {
            canStart = index != nil && index! < self.canStartQuest.count ? self.canStartQuest[index!] : false
        } else if isQuestStep {
            canStart = self.questStepComplete ?? false
        }
        
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = .clear
        circleRenderer.fillColor = canStart ? UIColor.green.withAlphaComponent(0.4) : UIColor.red.withAlphaComponent(0.4)
        return circleRenderer
    }
}
