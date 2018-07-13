//
//  Route.swift
//  tpg offline
//
//  Created by Remy on 09/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import Foundation

struct Route: Codable, Equatable {
  var from: Stop?
  var to: Stop?
  var via: [Stop]? = []
  var date: Date = Date()
  var arrivalTime: Bool = false
  var validRoute: RouteValidation {
    if from == nil && to == nil {
      return .departureAndArrivalMissing
    } else if from == nil {
      return .departureMissing
    } else if to == nil {
      return .arrivalMissing
    } else if from! == to! && (via?.isEmpty ?? true) {
      return .sameDepartureAndArrival
    } else {
      return .valid
    }
  }

  enum RouteValidation {
    case valid
    case sameDepartureAndArrival
    case departureAndArrivalMissing
    case departureMissing
    case arrivalMissing
  }

  static func == (lhs: Route, rhs: Route) -> Bool {
    return lhs.from?.appId == rhs.from?.appId &&
      lhs.to?.appId == rhs.to?.appId &&
      (lhs.via ?? []).map({ $0.appId }) == (rhs.via ?? []).map({ $0.appId })
  }
}
