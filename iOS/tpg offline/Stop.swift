//
//  Stop.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

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
        fullName = decoder.decodeObjectForKey("fullName") as! String
        title = decoder.decodeObjectForKey("title") as! String
        subTitle = decoder.decodeObjectForKey("subTitle") as! String
        stopCode = decoder.decodeObjectForKey("stopCode") as! String
        transportAPIiD = decoder.decodeObjectForKey("transportAPIiD") as! String
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
        if let fullName = fullName { coder.encodeObject(fullName, forKey: "fullName") }
        if let title = title { coder.encodeObject(title, forKey: "title") }
        if let subTitle = subTitle { coder.encodeObject(subTitle, forKey: "subTitle") }
        if let stopCode = stopCode { coder.encodeObject(stopCode, forKey: "stopCode") }
        if let location = location { coder.encodeObject(location, forKey: "location") }
        if let transportAPIiD = transportAPIiD { coder.encodeObject(transportAPIiD, forKey: "transportAPIiD") }
        if let connections = connections { coder.encodeObject(connections, forKey: "connections") }
    }
    
    init(stop: Arret) {
        fullName = stop.nomComplet
        title = stop.titre
        subTitle = stop.sousTitre
        stopCode = stop.stopCode
        location = stop.location
        distance = stop.distance
        transportAPIiD = stop.idTransportAPI
        connections = stop.connections
    }
    
    init(dictionnary: [String:AnyObject]) {
        fullName = dictionnary["fullName"] as? String ?? ""
        title = dictionnary["title"] as? String ?? ""
        subTitle = dictionnary["subTitle"] as? String ?? ""
        stopCode = dictionnary["stopCode"] as? String ?? ""
        location = dictionnary["location"] as? CLLocation ?? CLLocation(latitude: 46.204705, longitude: 6.143060)
        transportAPIiD = dictionnary["transportAPIiD"] as? String ?? ""
        connections = dictionnary["connections"] as? [String] ?? []
    }
    
    func toDictionnary() -> [String:AnyObject] {
        let attributes = [
            "fullName": fullName,
            "title": title,
            "subTitle": subTitle,
            "stopCode": stopCode,
            "transportAPIid": transportAPIiD,
            "location": location,
            "connections": connections
        ]
        return attributes
    }
}

// WARNING : Old class. Use Stop instead
internal class Arret : NSObject, NSCoding {
    var nomComplet: String!
    var titre: String!
    var sousTitre: String!
    var stopCode: String!
    var location: CLLocation!
    var distance: Double?
    var idTransportAPI: String!
    var connections: [String]!
    
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()
        nomComplet = decoder.decodeObjectForKey("nomComplet") as! String
        titre = decoder.decodeObjectForKey("titre") as! String
        sousTitre = decoder.decodeObjectForKey("sousTitre") as! String
        stopCode = decoder.decodeObjectForKey("stopCode") as! String
        idTransportAPI = decoder.decodeObjectForKey("idTransportAPI") as! String
        location = decoder.decodeObjectForKey("location") as! CLLocation
        connections = decoder.decodeObjectForKey("connections") as? [String] ?? []
    }
    convenience init(nomComplet: String, titre: String, sousTitre: String, stopCode: String, location: CLLocation, idTransportAPI: String, connections: [String]) {
        self.init()
        self.nomComplet = nomComplet
        self.titre = titre
        self.sousTitre = sousTitre
        self.stopCode = stopCode
        self.location = location
        self.idTransportAPI = idTransportAPI
        self.connections = connections
    }
    
    func encodeWithCoder(coder: NSCoder) {
        if let nomComplet = nomComplet { coder.encodeObject(nomComplet, forKey: "nomComplet") }
        if let titre = titre { coder.encodeObject(titre, forKey: "titre") }
        if let sousTitre = sousTitre { coder.encodeObject(sousTitre, forKey: "sousTitre") }
        if let stopCode = stopCode { coder.encodeObject(stopCode, forKey: "stopCode") }
        if let location = location { coder.encodeObject(location, forKey: "location") }
        if let idTransportAPI = idTransportAPI { coder.encodeObject(idTransportAPI, forKey: "idTransportAPI") }
        if let connections = connections { coder.encodeObject(connections, forKey: "connections") }
    }
}