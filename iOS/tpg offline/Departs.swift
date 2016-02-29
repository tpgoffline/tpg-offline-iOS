//
//  Departs.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/12/2015.
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
		let time = dateFormatter.dateFromString(timestamp)
		let tempsTimestamp: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time!)
		let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: NSDate())
		if tempsTimestamp.hour == now.hour && tempsTimestamp.minute == now.minute && tempsTimestamp.second >= now.second {
			self.tempsRestant =  "0"
		}
		else if tempsTimestamp.hour == now.hour && tempsTimestamp.minute - 1 == now.minute && tempsTimestamp.second <= now.second {
			self.tempsRestant =  "0"
		}
		else if tempsTimestamp.hour == now.hour && tempsTimestamp.minute > now.minute {
			self.tempsRestant = String(tempsTimestamp.minute - now.minute)
		}
		else if tempsTimestamp.hour > now.hour && tempsTimestamp.hour == now.hour + 1 && tempsTimestamp.minute < now.minute {
			self.tempsRestant = String((60 - now.minute) + tempsTimestamp.minute)
		}
		else if tempsTimestamp.hour > now.hour {
			self.tempsRestant = String(((tempsTimestamp.hour - now.hour) * 60) + tempsTimestamp.minute)
		}
		else {
			self.tempsRestant =  "-1"
		}
    }
}