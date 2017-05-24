//
//  CameraViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/24/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var input: AVCaptureInput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = self.view.bounds
            self.view.layer.addSublayer(previewLayer)
        } catch { }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.session?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.session?.stopRunning()
    }
}
