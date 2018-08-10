//
//  SmartNotificationStatus.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/03/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import Foundation

struct SmartNotificationStatus: Codable {
  var estimatedTriggerTime: Date
  var title: String
  var text: String
  var id: Int
}
