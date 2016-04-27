//
//  Itineraire.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

internal class Itineraire: NSObject, NSCoding {
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
	}
	
	convenience init(depart: Arret?, arrivee: Arret?, date: NSDateComponents?, dateArrivee: Bool!) {
		self.init()
		self.depart = depart
		self.arrivee = arrivee
		self.date = date
		self.dateArrivee = dateArrivee
	}
	
	
	convenience init(depart: Arret?, arrivee: Arret?) {
		self.init()
		self.depart = depart
		self.arrivee = arrivee
		self.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
		self.dateArrivee = false
	}
	
	func encodeWithCoder(coder: NSCoder) {
		if let depart = depart { coder.encodeObject(depart, forKey: "depart") }
		if let arrivee = arrivee { coder.encodeObject(arrivee, forKey: "arrivee") }
	}
}