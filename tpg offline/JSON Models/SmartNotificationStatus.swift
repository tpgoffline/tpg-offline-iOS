//
//  SmartNotificationStatus.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 18/03/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import Foundation

struct SmartNotificationStatus: Codable {
  var estimatedTriggerTime: Date
  var title: String
  var text: String
  var id: Int
}
