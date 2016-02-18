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
	var id: NSUUID!
	
	override init() {
		super.init()
	}
	required convenience init(coder decoder: NSCoder) {
		self.init()
		depart = (decoder.decodeObjectForKey("depart") as! Arret)
		arrivee = (decoder.decodeObjectForKey("arrivee") as! Arret)
		id = (decoder.decodeObjectForKey("id") as! NSUUID)
	}
	convenience init(depart: Arret?, arrivee: Arret?, date: NSDateComponents?, dateArrivee: Bool!) {
		self.init()
		self.depart = depart
		self.arrivee = arrivee
		self.date = date
		self.dateArrivee = dateArrivee
		self.id = NSUUID()
	}
	convenience init(itineraire: Itineraire) {
		self.init()
		self.depart = itineraire.depart
		self.arrivee = itineraire.arrivee
		self.date = itineraire.date
		self.dateArrivee = itineraire.dateArrivee
		self.id = itineraire.id
	}
	convenience init(depart: Arret?, arrivee: Arret?) {
		self.init()
		self.depart = depart
		self.arrivee = arrivee
		self.date = nil
		self.dateArrivee = nil
		self.id = NSUUID()
	}
	
	func encodeWithCoder(coder: NSCoder) {
		if let depart = depart { coder.encodeObject(depart, forKey: "depart") }
		if let arrivee = arrivee { coder.encodeObject(arrivee, forKey: "arrivee") }
		if let id = id { coder.encodeObject(id, forKey: "id") }
	}
	
	func setCurrentDate() {
		self.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
		self.dateArrivee = false
	}
}