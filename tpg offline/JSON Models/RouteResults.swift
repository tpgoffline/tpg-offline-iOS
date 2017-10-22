//
//  RouteResults.swift
//  tpg offline
//
//  Created by Remy on 10/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import Foundation

struct RouteResults: Decodable {
    var connections: [RouteConnection]
}

struct RouteConnection: Decodable {
    var duration: String?
    var from: RouteResultsStops
    var to: RouteResultsStops
    var sections: [Sections]?

    struct RouteResultsStops: Decodable {
        struct Station: Decodable {
            var id: String
            var name: String
            var coordinate: Coordinate

            struct Coordinate: Decodable {
                var x: Double
                var y: Double
            }
        }

        var departureTimestamp: Int?
        var arrivalTimestamp: Int?
        var station: Station
    }

    struct Sections: Decodable {
        struct Walk: Decodable {
            var duration: Int?
        }

        struct Journey: Decodable {
            var lineCode: String
            var compagny: String
            var category: String
            var to: String
            var passList: [RouteResultsStops]

            public init(lineCode: String, compagny: String, category: String, to: String, passList: [RouteResultsStops]) {
                self.lineCode = lineCode
                self.compagny = compagny
                self.category = category
                self.to = to
                self.passList = passList
            }

            enum CodingKeys: String, CodingKey {
                case lineCode = "number"
                case compagny = "operator"
                case category
                case to
                case passList
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                let lineCode = try container.decode(String.self, forKey: .lineCode)
                let compagny = try container.decode(String.self, forKey: .compagny)
                let category = try container.decode(String.self, forKey: .category)
                let to = try container.decode(String.self, forKey: .to)
                let passList = try container.decode([RouteResultsStops].self, forKey: .passList)

                self.init(lineCode: lineCode, compagny: compagny, category: category, to: to, passList: passList)
            }
        }

        var walk: Walk?
        var journey: Journey?
        var departure: RouteResultsStops
        var arrival: RouteResultsStops
    }
}
