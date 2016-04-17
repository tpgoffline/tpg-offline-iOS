//
//  Thermometer.swift
//  tpg offline
//
//  Created by Alice on 12/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import Foundation

class Thermometer {
    var tempsRestant: String?
    var devie: Bool!
    var correspondance1: String?
    var correspondance2: String?
    var correspondance3: String?
    var correspondance4: String?
    var arret: Arret!
    
    init(arret: Arret!, tempsRestant: String?, devie:Bool!, correspondance1: String?, correspondance2: String?, correspondance3: String?, correspondance4: String?) {
        self.arret = arret
        self.tempsRestant = tempsRestant
        self.devie = devie
        self.correspondance1 = correspondance1
        self.correspondance2 = correspondance2
        self.correspondance3 = correspondance3
        self.correspondance4 = correspondance4
    }
}