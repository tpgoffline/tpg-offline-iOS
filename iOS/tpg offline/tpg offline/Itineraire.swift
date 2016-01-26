//
//  Itineraire.swift
//  tpg offline
//
//  Created by Alice on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class Itineraire: NSObject, NSCoding {
    var depart: Arret?
    var arrivee: Arret?
    var date: NSDateComponents?
    var dateArrivee: Bool!
    
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()
        depart = (decoder.decodeObjectForKey("depart") as! Arret)
        arrivee = (decoder.decodeObjectForKey("arrivee") as! Arret)
        date = (decoder.decodeObjectForKey("date") as! NSDateComponents)
        dateArrivee = decoder.decodeObjectForKey("dateArrivee") as! Bool
    }
    convenience init(depart: Arret?, arrivee: Arret?, date: NSDateComponents?, dateArrivee: Bool!) {
        self.init()
        self.depart = depart
        self.arrivee = arrivee
        self.date = date
        self.dateArrivee = dateArrivee

    }
    
    func encodeWithCoder(coder: NSCoder) {
        if let depart = depart { coder.encodeObject(depart, forKey: "depart") }
        if let arrivee = arrivee { coder.encodeObject(arrivee, forKey: "arrivee") }
        if let date = date { coder.encodeObject(date, forKey: "date") }
        if let dateArrivee = dateArrivee { coder.encodeObject(dateArrivee, forKey: "dateArrivee") }
    }
}