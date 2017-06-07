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
    func showOverlay(named: String?)
}

class CameraView: UIView, CameraViewInterface {
    
    var view: UIView!
    weak var manager: QuestManagerDelegate?
    
    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var input: AVCaptureInput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var imageView: UIImageView!
    var imageTop: NSLayoutConstraint!
    var imageBottom: NSLayoutConstraint!
    var imageLeft: NSLayoutConstraint!
    var imageRight: NSLayoutConstraint!
    
    var visualInsets: UIEdgeInsets = .zero {
        didSet {
            self.imageTop.constant = visualInsets.top
            self.imageBottom.constant = visualInsets.bottom
            self.imageLeft.constant = visualInsets.left
            self.imageRight.constant = visualInsets.right
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
        
        self.configureImageView()
    }
    
    func configureImageView() {
        guard self.imageView == nil else {
            return
        }
        
        self.imageView = UIImageView(frame: self.view.frame)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.backgroundColor = .clear
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.alpha = 0.5
        
        self.view.addSubview(imageView)
        
        self.imageTop = NSLayoutConstraint(item: self.imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        self.imageBottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.imageView, attribute: .bottom, multiplier: 1, constant: 0)
        self.imageLeft = NSLayoutConstraint(item: self.imageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        self.imageRight = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.imageView, attribute: .right, multiplier: 1, constant: 0)
        self.addConstraints([self.imageTop, self.imageBottom, self.imageLeft, self.imageRight])
    }
    
    // MARK: - Exernal Managment
    
    func startUpdating() {
        self.session?.startRunning()
    }
    
    func stopUpdating() {
        self.session?.stopRunning()
    }
    
    // MARK: - Camera View Interface
    
    func showOverlay(named: String?) {
        self.configureImageView()
        self.imageView.image = named == nil ? nil : UIImage(named: "overlay_\(named!)")
    }
}
