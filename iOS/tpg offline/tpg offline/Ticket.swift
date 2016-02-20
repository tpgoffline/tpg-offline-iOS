//
//  Ticket.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 21/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class Ticket {
    var nom: String!
    var prix: String!
    var code: String!
    var description: String!
    var heure: Bool!
    
    init(nom: String, prix: String, code:String, description: String, heure: Bool) {
        self.nom = nom
        self.prix = prix
        self.code = code
        self.description = description
        self.heure = heure
    }
}