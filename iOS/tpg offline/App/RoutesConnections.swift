//
//  RoutesConnections.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import FontAwesomeKit

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
    var to: String
    var direction: String
    var departureTimestamp: Int
    var arrivalTimestamp: Int

    init(isWalk: Bool = true, from: String, to: String, departureTimestamp: Int, arrivalTimestamp: Int, direction: String) {
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
    
    init(line: String, isTpg: Bool, isSBB: Bool, transportCategory: Int, from: String, to: String, direction: String, departureTimestamp: Int, arrivalTimestamp: Int) {
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
    
    func getImageofType(_ size: CGFloat! = 24, color: UIColor! = UIColor.white) -> UIImage! {
        var icon: FAKIonIcons!
        switch transportCategory {
        case .bus:
            icon = FAKIonIcons.androidBusIcon(withSize: size)
            break
            
        case .boat:
            icon = FAKIonIcons.androidBoatIcon(withSize: size)
            break
            
        case .subway:
            icon = FAKIonIcons.androidSubwayIcon(withSize: size)
            break
            
        case .walk:
            icon = FAKIonIcons.androidWalkIcon(withSize: size)
            break
            
        case .train:
            icon = FAKIonIcons.androidTrainIcon(withSize: size)
            break
        }
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        return icon.image(with: CGSize(width: size, height: size))
    }
    
    func getAttributedStringofType(_ size: CGFloat! = 24, color: UIColor! = UIColor.white) -> NSAttributedString! {
        var icon: FAKIonIcons!
        switch transportCategory {
        case .bus:
            icon = FAKIonIcons.androidBusIcon(withSize: size)
            break
            
        case .boat:
            icon = FAKIonIcons.androidBoatIcon(withSize: size)
            break
            
        case .subway:
            icon = FAKIonIcons.androidSubwayIcon(withSize: size)
            break
            
        case .walk:
            icon = FAKIonIcons.androidWalkIcon(withSize: size)
            break
            
        case .train:
            icon = FAKIonIcons.androidTrainIcon(withSize: size)
            break
        }
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        return icon.attributedString()
    }
}
