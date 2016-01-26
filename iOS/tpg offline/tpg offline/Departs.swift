//
//  Departs.swift
//  tpg offline
//
//  Created by Alice on 22/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class Departs {
    var ligne: String!
    var direction: String!
    var couleur: UIColor!
    var couleurArrierePlan: UIColor!
    var code: String!
    var tempsRestant: String!
    var timestamp: String!
    
    init(ligne: String, direction: String, couleur: UIColor, couleurArrierePlan: UIColor, code: String, tempsRestant: String, timestamp: String) {
        self.ligne = ligne
        self.direction = direction
        self.couleur = couleur
        self.couleurArrierePlan = couleurArrierePlan
        self.code = code
        self.tempsRestant = tempsRestant
        self.timestamp = timestamp
    }
}