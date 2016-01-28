//
//  Departs.swift
//  tpg offline
//
//  Created by Alice on 22/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class Departs {
    var ligne: String!
    var direction: String!
    var couleur: UIColor!
    var couleurArrierePlan: UIColor!
    var code: String?
    var tempsRestant: String!
    var timestamp: String!
    
    init(ligne: String!, direction: String!, couleur: UIColor!, couleurArrierePlan: UIColor!, code: String?, tempsRestant: String?, timestamp: String!) {
        self.ligne = ligne
        self.direction = direction
        self.couleur = couleur
        self.couleurArrierePlan = couleurArrierePlan
        self.code = code
        self.tempsRestant = tempsRestant
        self.timestamp = timestamp
    }
    
    func calculerTempsRestant() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.dateFromString(self.timestamp)
        print(NSDateComponents().calendar?.compareDate(NSDate(), toDate: time!, toUnitGranularity: [NSCalendarUnit.Hour, NSCalendarUnit.Minute]))
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: time!)
        let nows: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate())
        if now.hour <= nows.hour && now.minute < nows.minute {
            self.tempsRestant = "-1"
        }
        else {
            self.tempsRestant = String(((now.hour - nows.hour) * 60) + now.minute - nows.minute)
        }
    }
}