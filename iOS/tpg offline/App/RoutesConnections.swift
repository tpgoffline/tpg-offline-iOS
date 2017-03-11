//
//  RoutesConnections.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

enum RoutesTransportCategory {
    case bus
    case boat
    case subway
    case train
    case walk
}

internal class RoutesConnections {
    var line: String
    var isTpg: Bool
    var isSBB: Bool
    var transportCategory: RoutesTransportCategory
    var from: String
    var to: String // swiftlint:disable:this variable_name
    var direction: String
    var departureTimestamp: Int
    var arrivalTimestamp: Int
    var image: UIImage {
        var icon: UIImage!
        switch transportCategory {
        case .bus:
            icon = #imageLiteral(resourceName: "bus")
            break

        case .boat:
            icon = #imageLiteral(resourceName: "boat")
            break

        case .subway:
            icon = #imageLiteral(resourceName: "subway")
            break

        case .walk:
            icon = #imageLiteral(resourceName: "walking")
            break

        case .train:
            icon = #imageLiteral(resourceName: "train")
            break
        }
        return icon
    }

    init(isWalk: Bool = true,
         from: String,
         to: String, // swiftlint:disable:this variable_name
         departureTimestamp: Int,
         arrivalTimestamp: Int,
         direction: String) {
        self.line = ""
        self.isTpg = false
        self.isSBB = false
        self.transportCategory = .walk
        self.from = from
        self.to = to
        self.departureTimestamp = departureTimestamp
        self.arrivalTimestamp = arrivalTimestamp
        self.direction = direction
    }

    init(line: String,
         isTpg: Bool,
         isSBB: Bool,
         transportCategory: Int,
         from: String,
         to: String, // swiftlint:disable:this variable_name
         direction: String,
         departureTimestamp: Int,
         arrivalTimestamp: Int) {
        self.line = line
        self.isTpg = isTpg
        self.isSBB = isSBB
        switch transportCategory {
        case 6:
            self.transportCategory = .bus
            break

        case 4:
            self.transportCategory = .boat
            break

        case 9:
            self.transportCategory = .subway
            break

        default:
            self.transportCategory = .train
        }
        self.from = from
        self.to = to
        self.direction = direction
        self.departureTimestamp = departureTimestamp
        self.arrivalTimestamp = arrivalTimestamp
    }
}
