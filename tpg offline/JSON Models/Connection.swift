//
//  Connection.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 14/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import Foundation

struct Connection: Codable {
  var destinationCode: String
  var line: String
  var destinationName: String

  enum CodingKeys: String, CodingKey {
    case destinationCode
    case line = "lineCode"
    case destinationName
  }
}
