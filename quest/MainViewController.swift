//
//  MainViewController.swift
//  quest
//
//  Created by Nathan Tornquist on 5/17/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let destinations: [String] = [
        "North",
        "The Bagel",
        "Reside on Barry",
        "Wellington Brown Line",
        "Industrious"
    ]
    
    let destinationCoords: [CLLocationCoordinate2D?] = [
        nil,
        CLLocationCoordinate2D(latitude: 41.937869, longitude: -87.644062),
        CLLocationCoordinate2D(latitude: 41.937494, longitude: -87.643386),
        CLLocationCoordinate2D(latitude: 41.936223, longitude: -87.653409),
        CLLocationCoordinate2D(latitude: 41.892566, longitude: -87.636641),
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Navigation Options"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = destinations[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let compass = UIStoryboard(name: "Compass", bundle: nil).instantiateViewController(withIdentifier: "compassView") as! CompassViewController
        compass.currentDestination = destinationCoords[indexPath.row]
        compass.navigationItem.title = destinations[indexPath.row]
        self.navigationController?.pushViewController(compass, animated: true)
    }
}
