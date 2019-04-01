//
//  LandingViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/24/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class LandingViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var needsLocation = true
    var deniedLocation = false
    var needsCamera = true
    var deniedCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshAuth()
        self.updateText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.needsLocation && !self.needsCamera {
            self.showHomescreen(animated: false)
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        self.authPrompt()
    }
    
    func showHomescreen(animated: Bool) {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        self.present(mainVC, animated: animated, completion: nil)
    }
    
    // MARK: - Copy Changes
    
    func updateText() {
        if self.showSettings() {
            self.descriptionLabel.text = "NavQuest is a GPS and camera based scavenger hunt. It requires camera and location access to function. To play the game, please press settings to open the settings menu and grant access"
            self.continueButton.setTitle("Settings", for: .normal)
        } else {
            self.descriptionLabel.text = "NavQuest is a GPS and camera based scavenger hunt. It requires camera and location access to function. To play the game, please press continue and then grant access."
            self.continueButton.setTitle("Continue", for: .normal)
        }
    }
    
    // MARK: - Permissions Lifecycle
    
    func showSettings() -> Bool {
        return self.deniedCamera || self.deniedLocation
    }
    
    func refreshAuth() {
        let locationStatus = CLLocationManager.authorizationStatus()
        self.needsLocation = locationStatus != CLAuthorizationStatus.authorizedWhenInUse
        self.deniedLocation = locationStatus == CLAuthorizationStatus.denied
        
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.needsCamera = cameraStatus != AVAuthorizationStatus.authorized
        self.deniedCamera = cameraStatus == AVAuthorizationStatus.denied
    }
    
    func authPrompt() {
        if self.showSettings() {
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        } else if self.needsLocation {
            locationManager.requestWhenInUseAuthorization()
        } else if self.needsCamera {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.authHandler(success: granted)
                }
            }
        } else {
            self.showHomescreen(animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authHandler(success: status == .authorizedWhenInUse)
        }
    }
    
    func authHandler(success: Bool) {
        self.refreshAuth()
        self.updateText()
        if success {
            self.authPrompt()
        }
    }
}
