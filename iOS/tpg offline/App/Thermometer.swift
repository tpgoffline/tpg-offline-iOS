//
//  Thermometer.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 12/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import Foundation

internal class Thermometer {
    var leftTime: String?
    var isDeflect: Bool!
    var connection1: String?
    var connection2: String?
    var connection3: String?
    var connection4: String?
    var stop: Stop!
    
    init(stop: Stop!, leftTime: String?, isDeflect:Bool!, connection1: String?, connection2: String?, connection3: String?, connection4: String?) {
        self.stop = stop
        self.leftTime = leftTime
        self.isDeflect = isDeflect
        self.connection1 = connection1
        self.connection2 = connection2
        self.connection3 = connection3
        self.connection4 = connection4
    }
}