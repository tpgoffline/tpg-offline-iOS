//
//  Arret.swift
//  tpg offline
//
//  Created by Alice on 11/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class Arret : NSObject, NSCoding {
    var nomComplet: String!
    var titre: String!
    var sousTitre: String!
    var stopCode: String!
    
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()
        nomComplet = decoder.decodeObjectForKey("nomComplet") as! String
        titre = decoder.decodeObjectForKey("titre") as! String
        sousTitre = decoder.decodeObjectForKey("sousTitre") as! String
        stopCode = decoder.decodeObjectForKey("stopCode") as! String
    }
    convenience init(nomComplet: String, titre: String, sousTitre: String, stopCode: String) {
        self.init()
        self.nomComplet = nomComplet
        self.titre = titre
        self.sousTitre = sousTitre
        self.stopCode = stopCode
    }

    func encodeWithCoder(coder: NSCoder) {
        if let nomComplet = nomComplet { coder.encodeObject(nomComplet, forKey: "nomComplet") }
        if let titre = titre { coder.encodeObject(titre, forKey: "titre") }
        if let sousTitre = sousTitre { coder.encodeObject(sousTitre, forKey: "sousTitre") }
        if let stopCode = stopCode { coder.encodeObject(stopCode, forKey: "stopCode") }
    }
}