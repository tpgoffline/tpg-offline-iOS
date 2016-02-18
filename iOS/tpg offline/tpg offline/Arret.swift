//
//  Arret.swift
//  tpg offline
//
//  Created by Alice on 11/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import CoreLocation

class Arret : NSObject, NSCoding {
    var nomComplet: String!
    var titre: String!
    var sousTitre: String!
    var stopCode: String!
    var location: CLLocation!
    var distance: Double?
    var idTransportAPI: String!
	
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
    }
    convenience init(nomComplet: String, titre: String, sousTitre: String, stopCode: String, location: CLLocation, idTransportAPI: String) {
        self.init()
        self.nomComplet = nomComplet
        self.titre = titre
        self.sousTitre = sousTitre
        self.stopCode = stopCode
        self.location = location
        self.idTransportAPI = idTransportAPI
    }

    func encodeWithCoder(coder: NSCoder) {
        if let nomComplet = nomComplet { coder.encodeObject(nomComplet, forKey: "nomComplet") }
        if let titre = titre { coder.encodeObject(titre, forKey: "titre") }
        if let sousTitre = sousTitre { coder.encodeObject(sousTitre, forKey: "sousTitre") }
        if let stopCode = stopCode { coder.encodeObject(stopCode, forKey: "stopCode") }
        if let location = location { coder.encodeObject(location, forKey: "location") }
        if let idTransportAPI = idTransportAPI { coder.encodeObject(idTransportAPI, forKey: "idTransportAPI") }
    }
}