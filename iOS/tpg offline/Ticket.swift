//
//  Ticket.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 21/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class Ticket {
    var name: String!
    var price: String!
    var smsCode: String!
    var description: String!
    var isValidOneHour: Bool!
    
    init(name: String, price: String, smsCode:String, description: String, isValidOneHour: Bool) {
        self.name = name
        self.price = price
        self.smsCode = smsCode
        self.description = description
        self.isValidOneHour = isValidOneHour
    }
}