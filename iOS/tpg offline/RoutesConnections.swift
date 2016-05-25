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
    case Bus
    case Boat
    case Subway
    case Train
    case Walk
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
        self.transportCategory = .Walk
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
            self.transportCategory = .Bus
            break
            
        case 4:
            self.transportCategory = .Boat
            break
            
        case 9:
            self.transportCategory = .Subway
            break
            
        default:
            self.transportCategory = .Train
        }
        self.from = from
        self.to = to
        self.direction = direction
        self.departureTimestamp = departureTimestamp
        self.arrivalTimestamp = arrivalTimestamp
    }
    
    func getImageofType(size: CGFloat! = 24, color: UIColor! = UIColor.whiteColor()) -> UIImage! {
        var icon: FAKIonIcons!
        switch transportCategory {
        case .Bus:
            icon = FAKIonIcons.androidBusIconWithSize(size)
            break
            
        case .Boat:
            icon = FAKIonIcons.androidBoatIconWithSize(size)
            break
            
        case .Subway:
            icon = FAKIonIcons.androidSubwayIconWithSize(size)
            break
            
        case .Walk:
            icon = FAKIonIcons.androidWalkIconWithSize(size)
            break
            
        case .Train:
            icon = FAKIonIcons.androidTrainIconWithSize(size)
            break
        }
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        return icon.imageWithSize(CGSize(width: size, height: size))
    }
    
    func getAttributedStringofType(size: CGFloat! = 24, color: UIColor! = UIColor.whiteColor()) -> NSAttributedString! {
        var icon: FAKIonIcons!
        switch transportCategory {
        case .Bus:
            icon = FAKIonIcons.androidBusIconWithSize(size)
            break
            
        case .Boat:
            icon = FAKIonIcons.androidBoatIconWithSize(size)
            break
            
        case .Subway:
            icon = FAKIonIcons.androidSubwayIconWithSize(size)
            break
            
        case .Walk:
            icon = FAKIonIcons.androidWalkIconWithSize(size)
            break
            
        case .Train:
            icon = FAKIonIcons.androidTrainIconWithSize(size)
            break
        }
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        return icon.attributedString()
    }
}