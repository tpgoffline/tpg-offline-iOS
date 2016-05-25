//
//  Stop.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import CoreLocation

internal class Stop: NSObject, NSCoding {
    var fullName: String!
    var title: String!
    var subTitle: String!
    var stopCode: String!
    var location: CLLocation!
    var distance: Double?
    var transportAPIiD: String!
    var connections: [String]!
	
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()
        fullName = decoder.decodeObjectForKey("nomComplet") as! String
        title = decoder.decodeObjectForKey("titre") as! String
        subTitle = decoder.decodeObjectForKey("sousTitre") as! String
        stopCode = decoder.decodeObjectForKey("stopCode") as! String
        transportAPIiD = decoder.decodeObjectForKey("idTransportAPI") as! String
        location = decoder.decodeObjectForKey("location") as! CLLocation
        connections = decoder.decodeObjectForKey("connections") as? [String] ?? []
    }
    convenience init(fullName: String, title: String, subTitle: String, stopCode: String, location: CLLocation, transportAPIiD: String, connections: [String]) {
        self.init()
        self.fullName = fullName
        self.title = title
        self.subTitle = subTitle
        self.stopCode = stopCode
        self.location = location
        self.transportAPIiD = transportAPIiD
        self.connections = connections
    }

    func encodeWithCoder(coder: NSCoder) {
        if let nomComplet = fullName { coder.encodeObject(nomComplet, forKey: "nomComplet") }
        if let titre = title { coder.encodeObject(titre, forKey: "titre") }
        if let sousTitre = subTitle { coder.encodeObject(sousTitre, forKey: "sousTitre") }
        if let stopCode = stopCode { coder.encodeObject(stopCode, forKey: "stopCode") }
        if let location = location { coder.encodeObject(location, forKey: "location") }
        if let idTransportAPI = transportAPIiD { coder.encodeObject(idTransportAPI, forKey: "transportAPIiD") }
        if let connections = connections { coder.encodeObject(connections, forKey: "connections") }
    }
}