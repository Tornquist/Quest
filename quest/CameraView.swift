//
//  CameraView.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewInterface: class {
    
}

class CameraView: UIView, CameraViewInterface {
    
    var view: UIView!
    weak var manager: QuestManagerDelegate?
    
    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var input: AVCaptureInput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
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
        let nib = UINib(nibName: "CameraView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: - View Configuration
    
    func configureTheme() {
        self.backgroundColor = .clear
        self.view.backgroundColor = .clear
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.view.layer.addSublayer(previewLayer)
        } catch { }
    }
    
    // MARK: - Exernal Managment
    
    func startUpdating() {
        self.session?.startRunning()
    }
    
    func stopUpdating() {
        self.session?.stopRunning()
    }
}
