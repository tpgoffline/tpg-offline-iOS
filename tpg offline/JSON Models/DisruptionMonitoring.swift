//
//  DisruptionMonitoring.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import Foundation

struct DisruptionMonitoring: Codable, Equatable {
  var line: String
  var fromHour: String
  var toHour: String
  var days: String

  static func == (lhd: DisruptionMonitoring, rhd: DisruptionMonitoring) -> Bool {
    return lhd.line == rhd.line &&
      lhd.fromHour == rhd.fromHour &&
      lhd.toHour == rhd.toHour &&
      lhd.days == rhd.days
  }
}
