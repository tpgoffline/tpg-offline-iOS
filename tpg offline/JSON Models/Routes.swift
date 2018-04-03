//
//  Routes.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 31/03/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import Foundation

struct RouteStop: Decodable {
    struct NextStop: Decodable {
        let destinationCode: String
        let line: String
        let passRoute: [Int]
    }

    struct NearestStop: Decodable {
        let code: String
        let distance: Int
        let timeToWalk: Int
    }

    var nextStops: [NextStop]
    var nearestStops: [NearestStop]
}
