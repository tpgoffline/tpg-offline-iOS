//
//  Line.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
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
