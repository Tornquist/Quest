//
//  QuestProtocol.swift
//  quest
//
//  Created by Nathan Tornquist on 5/26/17.
//  Copyright © 2017 nathantornquist. All rights reserved.
//

import Foundation
import CoreLocation

protocol QuestProtocol: class {
    func startingPosition() -> CLLocationCoordinate2D
    func startingRadius() -> CLLocationDistance
}
