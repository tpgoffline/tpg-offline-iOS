//
//  Line.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 11/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import Foundation

struct Line: Codable {
    var courses: [[Int]]
    var snotpgURL: String
    var line: String
    var departureName: String
    var arrivalName: String
    var textFR: String?
    var textEN: String?
}
