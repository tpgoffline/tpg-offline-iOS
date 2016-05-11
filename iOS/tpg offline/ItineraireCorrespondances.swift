//
//  ItineraireCorrespondances.swift
//  tpg offline
//
//  Created by Alice on 09/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import FontAwesomeKit

enum ItineraireCategorieTransport {
    case Bus
    case Bateau
    case Metro
    case Train
    case Marche
}

internal class ItineraireCorrespondances {
    var ligne: String
    var isTpg: Bool
    var isSBB: Bool
    var categorie: ItineraireCategorieTransport
    var de: String
    var a: String
    var direction: String
    var timestampDepart: Int
    var timestampArrivee: Int
    
    init(isWalk: Bool = true, de: String, a: String, timestampDepart: Int, timestampArrivee: Int, direction: String) {
        self.ligne = ""
        self.isTpg = false
        self.isSBB = false
        self.categorie = .Marche
        self.de = de
        self.a = a
        self.timestampDepart = timestampDepart
        self.timestampArrivee = timestampArrivee
        self.direction = direction
    }
    
    init(ligne: String, isTpg: Bool, isSBB: Bool, categorie: Int, de: String, a: String, direction: String, timestampDepart: Int, timestampArrivee: Int) {
        self.ligne = ligne
        self.isTpg = isTpg
        self.isSBB = isSBB
        switch categorie {
        case 6:
            self.categorie = .Bus
            break
            
        case 4:
            self.categorie = .Bateau
            break
            
        case 9:
            self.categorie = .Metro
            break
            
        default:
            self.categorie = .Train
        }
        self.de = de
        self.a = a
        self.direction = direction
        self.timestampDepart = timestampDepart
        self.timestampArrivee = timestampArrivee
    }
    
    func getImageofType(size: CGFloat! = 24, color: UIColor! = UIColor.whiteColor()) -> UIImage! {
        var icone: FAKIonIcons!
        switch categorie {
        case .Bus:
            icone = FAKIonIcons.androidBusIconWithSize(size)
            break
            
        case .Bateau:
            icone = FAKIonIcons.androidBoatIconWithSize(size)
            break
            
        case .Metro:
            icone = FAKIonIcons.androidSubwayIconWithSize(size)
            break
            
        case .Marche:
            icone = FAKIonIcons.androidWalkIconWithSize(size)
            break
            
        case .Train:
            icone = FAKIonIcons.androidTrainIconWithSize(size)
            break
        }
        icone.addAttribute(NSForegroundColorAttributeName, value: color)
        return icone.imageWithSize(CGSize(width: size, height: size))
    }
    
    func getAttributedStringofType(size: CGFloat! = 24, color: UIColor! = UIColor.whiteColor()) -> NSAttributedString! {
        var icone: FAKIonIcons!
        switch categorie {
        case .Bus:
            icone = FAKIonIcons.androidBusIconWithSize(size)
            break
            
        case .Bateau:
            icone = FAKIonIcons.androidBoatIconWithSize(size)
            break
            
        case .Metro:
            icone = FAKIonIcons.androidSubwayIconWithSize(size)
            break
            
        case .Marche:
            icone = FAKIonIcons.androidWalkIconWithSize(size)
            break
            
        case .Train:
            icone = FAKIonIcons.androidTrainIconWithSize(size)
            break
        }
        icone.addAttribute(NSForegroundColorAttributeName, value: color)
        return icone.attributedString()
    }
}