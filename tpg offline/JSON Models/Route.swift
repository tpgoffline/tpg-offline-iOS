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
    var validRoute: Bool {
        return from != nil && to != nil
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.from?.appId == rhs.from?.appId &&
            lhs.to?.appId == rhs.to?.appId && (lhs.via ?? []).map({ $0.appId }) == (rhs.via ?? []).map({ $0.appId })
    }
}
