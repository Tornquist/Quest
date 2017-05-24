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

class LandingViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    
    var needsLocation = true
    var deniedLocation = false
    var needsCamera = true
    var deniedCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationStatus = CLLocationManager.authorizationStatus()
        self.needsLocation = locationStatus != CLAuthorizationStatus.authorizedWhenInUse
        self.deniedLocation = locationStatus == CLAuthorizationStatus.denied
        
        let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        self.needsCamera = cameraStatus != AVAuthorizationStatus.authorized
        self.deniedCamera = cameraStatus == AVAuthorizationStatus.denied
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.needsLocation && !self.needsCamera {
            self.showHomescreen(animated: false)
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        self.showHomescreen(animated: true)
    }
    
    func showHomescreen(animated: Bool) {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        self.present(mainVC, animated: animated, completion: nil)
    }
}

