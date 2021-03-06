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
    
    var imageZoomSlider: UISlider!
    
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
        self.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
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
        session.sessionPreset = AVCaptureSession.Preset.high
        
        device = AVCaptureDevice.default(for: .video)
        
        do {
            guard device != nil else {
                throw NSError(domain: "ShortCircuitBlock", code: 000, userInfo: nil)
            }
            
            input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
        
        self.imageTop = NSLayoutConstraint(item: self.imageView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        self.imageBottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.imageView, attribute: .bottom, multiplier: 1, constant: 0)
        self.imageLeft = NSLayoutConstraint(item: self.imageView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        self.imageRight = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.imageView, attribute: .right, multiplier: 1, constant: 0)
        self.addConstraints([self.imageTop, self.imageBottom, self.imageLeft, self.imageRight])
        
        self.imageZoomSlider = UISlider()
        self.imageZoomSlider.translatesAutoresizingMaskIntoConstraints = false
        let sliderLeft = NSLayoutConstraint(item: self.imageZoomSlider!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 16)
        let sliderRight = NSLayoutConstraint(item: self.imageZoomSlider!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: -16)
        let sliderBottom = NSLayoutConstraint(item: self.imageZoomSlider!, attribute: .bottom, relatedBy: .equal, toItem: self.imageView, attribute: .bottom, multiplier: 1, constant: -16)
        self.imageZoomSlider.minimumValue = 1
        self.imageZoomSlider.setValue(1, animated: false)
        self.imageZoomSlider.maximumValue = 3
        self.imageZoomSlider.minimumTrackTintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        self.view.addSubview(self.imageZoomSlider)
        self.view.addConstraints([sliderLeft, sliderRight, sliderBottom])
        self.imageZoomSlider.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
    }
    
    @objc func sliderDidChange(sender: UISlider) {
        let constraintConstant = self.view.frame.width * CGFloat(1.0 - sender.value)
        
        self.imageLeft.constant = constraintConstant
        self.imageRight.constant = constraintConstant
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
        self.imageZoomSlider.isHidden = self.imageView.image == nil
    }
}
