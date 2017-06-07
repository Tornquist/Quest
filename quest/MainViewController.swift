//
//  MainViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/17/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum MainViewStyle: Int {
    case map = 0
    case compass = 1
    case camera = 2
}

protocol MainViewControllerInterface: class {
    func set(viewStyle: MainViewStyle)
    
    func showMessage(_ text: String)
    func hideMessage()
    
    func showButton(withTitle title: String)
    func hideButton()
    
    func quitButton(show: Bool)
    
    func askQuestionFor(step: QuestStep)
}

class MainViewController: UIViewController, CLLocationManagerDelegate, MainViewControllerInterface {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var compassView: CompassView!
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    var messageLabel: UILabel!
    var startButton: UIButton!
    
    var questManager: QuestManager!
    
    var viewStyle: MainViewStyle = .map
    
    @IBOutlet weak var bottomView: UIView!
    var bottomViewSwipeDown: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureQuestManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshView()
        
        // Compass view is current location/GPS manager
        // as well as a normal view component
        self.compassView.startUpdating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.refreshView()
        self.compassView.stopUpdating()
    }
    
    // MARK: - View Management
    
    func configureView() {
        self.mapView.visualInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.bounds.height/2, right: 0)
        self.cameraView.visualInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.bounds.height/2, right: 0)
        
        self.messageLabel = UILabel()
        self.messageLabel.text = "Walk to a quest marker to begin"
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textColor = .white
        self.messageLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        self.messageLabel.textAlignment = .center
        self.stackView.addArrangedSubview(self.messageLabel)
        self.messageLabel.isHidden = false
        
        self.startButton = UIButton()
        self.startButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.startButton.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        self.startButton.setTitle("START QUEST", for: .normal)
        self.startButton.setTitleColor(.white, for: .normal)
        self.startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        let heightConstraint = NSLayoutConstraint(item: self.startButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
        heightConstraint.priority = 999
        self.startButton.addConstraint(heightConstraint)
        self.startButton.layer.cornerRadius = 8
        self.stackView.addArrangedSubview(self.startButton)
        self.startButton.isHidden = true
        
        self.bottomViewSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        self.bottomViewSwipeDown.direction = .down
        self.bottomViewSwipeDown.numberOfTouchesRequired = 3
        self.bottomViewSwipeDown.cancelsTouchesInView = true
        self.bottomView.addGestureRecognizer(self.bottomViewSwipeDown)
    }
    
    func refreshView() {
        self.display(mode: self.viewStyle)
    }
    
    func display(mode: MainViewStyle) {
        self.compassView.isHidden = mode != .compass
        self.cameraView.isHidden = mode != .camera
        
        (mode == .camera ? self.cameraView.startUpdating() : self.cameraView.stopUpdating())
    }
    
    @IBAction func changedSegmentControl(_ sender: UISegmentedControl) {
        self.viewStyle = MainViewStyle.init(rawValue: sender.selectedSegmentIndex) ?? .map
        self.refreshView()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender == self.startButton {
            self.questManager.mainButtonPressed()
        } else if sender == self.closeButton {
            guard !self.questManager.questComplete() else {
                self.questManager.quit()
                return
            }
            
            let alert = UIAlertController(title: "Would you like to abandon your current quest?", message: "All progress will be lost. You can only resume from the beginning.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes, Quit", style: .destructive, handler: { (_) in
                self.questManager.quit()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Quest Managment
    
    func configureQuestManager() {
        self.questManager = QuestManager()
        
        self.questManager.mainInterface = self
        self.questManager.mapInterface = self.mapView
        self.questManager.compassInterface = self.compassView
        self.questManager.cameraInterface = self.cameraView
        
        self.mapView.manager = self.questManager
        self.compassView.manager = self.questManager
        self.cameraView.manager = self.questManager
        
        self.questManager.loadQuests()
        self.questManager.reset()
    }
    
    // MARK: - Public Interface
    
    func set(viewStyle: MainViewStyle) {
        self.viewStyle = viewStyle
        self.refreshView()
    }
    
    func showMessage(_ text: String) {
        self.messageLabel.isHidden = false
        self.messageLabel.text = text
    }
    func hideMessage() {
        self.messageLabel.isHidden = true
    }
    
    func showButton(withTitle title: String) {
        self.startButton.isHidden = false
        self.startButton.setTitle(title, for: .normal)
    }
    func hideButton() {
        self.startButton.isHidden = true
    }
    
    func quitButton(show: Bool) {
        self.closeButton.isHidden = !show
    }
    
    func askQuestionFor(step: QuestStep) {
        guard step.questionType != nil &&
            step.questionType! == .freeResponse else {
            print("Type not yet supported")
            return
        }
        
        let alertController = UIAlertController(title: step.question, message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Answer"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            
            let answerField = alertController.textFields![0] as UITextField
            step.userAnswer = answerField.text
            self.questManager.refreshViews()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Override Gestures
    
    func swipedDown(_ sender: UISwipeGestureRecognizer) {
        // TODO: Disable for final release
        
        self.questManager.showDebug(on: self)
    }
}
