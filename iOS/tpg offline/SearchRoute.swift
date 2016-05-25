//
//  SearchRoute.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

internal class SearchRoute: NSObject, NSCoding {
	var departure: Stop?
	var arrival: Stop?
	var date: NSDateComponents?
	var isArrivalDate: Bool!
	
	override init() {
		super.init()
	}

	required convenience init(coder decoder: NSCoder) {
		self.init()
		departure = (decoder.decodeObjectForKey("depart") as! Stop)
		arrival = (decoder.decodeObjectForKey("arrivee") as! Stop)
	}
	
	convenience init(departure: Stop?, arrival: Stop?, date: NSDateComponents?, isArrivalDate: Bool!) {
		self.init()
		self.departure = departure
		self.arrival = arrival
		self.date = date
		self.isArrivalDate = isArrivalDate
	}
	
	
	convenience init(departure: Stop?, arrival: Stop?) {
		self.init()
		self.departure = departure
		self.arrival = arrival
		self.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
		self.isArrivalDate = false
	}
	
	func encodeWithCoder(coder: NSCoder) {
		if let departure = departure { coder.encodeObject(departure, forKey: "depart") }
		if let arrival = arrival { coder.encodeObject(arrival, forKey: "arrivee") }
	}
}