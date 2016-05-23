//
//  Itineraire.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

internal class Itineraire {
    var de: String!
    var a: String!
    var duree: String!
    var timestampDepart: Int!
    var timestampArrivee: Int!
    var correspondances: [ItineraireCorrespondances]!
    init(de: String, a: String, duree: String, timestampDepart: Int!, timestampArrivee: Int!, correspondances: [ItineraireCorrespondances]) {
        self.de = de
        self.a = a
        self.duree = duree
        self.timestampDepart = timestampDepart
        self.timestampArrivee = timestampArrivee
        self.correspondances = correspondances
    }
    init() {
        self.de = ""
        self.a = ""
        self.duree = ""
        self.timestampDepart = 0
        self.timestampArrivee = 0
        self.correspondances = []
    }
}
