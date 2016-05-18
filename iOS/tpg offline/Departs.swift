//
//  Departs.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

internal class Departs {
    var ligne: String!
    var direction: String!
    var destinationCode: String!
    var couleur: UIColor!
    var couleurArrierePlan: UIColor!
    var code: String!
    var tempsRestant: String!
    var timestamp: String!
    var dateCompenents: NSDateComponents?
    
    init(ligne: String!, direction: String!, destinationCode: String, couleur: UIColor!, couleurArrierePlan: UIColor!, code: String!, tempsRestant: String?, timestamp: String!) {
        self.ligne = ligne
        self.direction = direction
        self.destinationCode = destinationCode
        self.couleur = couleur
        self.couleurArrierePlan = couleurArrierePlan
        self.code = code
        self.tempsRestant = tempsRestant
        self.timestamp = timestamp
    }
    
    func calculerTempsRestant() {
        if timestamp == nil {
            self.tempsRestant = "-1"
        }
        else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            let time = dateFormatter.dateFromString(timestamp)
            let tempsTimestamp: NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: time!)
            
            let now: NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate())
            tempsTimestamp.year = now.year
            tempsTimestamp.month = now.month
            tempsTimestamp.day = now.day
            
            dateCompenents = tempsTimestamp
            
            if NSCalendar.currentCalendar().dateFromComponents(tempsTimestamp)!.compare(NSDate()) == .OrderedAscending {
                self.tempsRestant = "-1"
            }
            else {
                self.tempsRestant = String(Int(NSCalendar.currentCalendar().dateFromComponents(tempsTimestamp)!.timeIntervalSinceNow / 60))
            }
        }
    }
}