//
//  MapCenterButton.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import UIKit

protocol MapCenterButtonDelegate: class {
    func centerButtonPressed(sender: MapCenterButton)
}

class MapCenterButton: UIView {
    
    var view: UIView!
    
    weak var delegate: MapCenterButtonDelegate?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var button: UIButton!
    
    var allowCenter: Bool = true {
        didSet {
            self.button.tintColor = allowCenter ? UIColor.white : UIColor.lightGray
            self.button.isEnabled = allowCenter
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
        let nib = UINib(nibName: "MapCenterButton", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: - View Configuration
    
    func configureTheme() {
        self.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor.clear
        
        self.containerView.backgroundColor = .clear
        self.containerView.layer.cornerRadius = 8
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.borderColor = UIColor.black.cgColor
        self.containerView.clipsToBounds = true
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.delegate?.centerButtonPressed(sender: self)
    }
}
