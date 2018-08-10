//
//  Connection.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 14/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
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
