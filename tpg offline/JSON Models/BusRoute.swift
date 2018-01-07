//
//  Thermometer.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 14/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

struct BusRouteGroup: Codable {
    var steps: [BusRoute]
    var lineCode: String
    var destination: String

    public init(steps: [BusRoute], lineCode: String, destination: String) {
        self.steps = steps
        self.lineCode = lineCode
        self.destination = destination

        self.steps[0].first = true
        self.steps[steps.endIndex - 1].last = true
    }

    enum CodingKeys: String, CodingKey {
        case steps
        case lineCode
        case destination = "destinationName"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let steps = try container.decode([BusRoute].self, forKey: .steps)
        let lineCode = try container.decode(String.self, forKey: .lineCode)
        let destination = try container.decode(String.self, forKey: .destination)

        self.init(steps: steps, lineCode: lineCode, destination: destination)
    }
}

struct BusRoute: Codable {
    struct Stop: Codable {
        let code: String
        let name: String
        let connections: [Connection]

        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case code = "stopCode"
            case name = "stopName"
            case connections
        }

        static func == (lhd: BusRoute.Stop, rhd: BusRoute.Stop) -> Bool {
            return lhd.code == rhd.code && lhd.name == rhd.code
        }
    }

    var stop: BusRoute.Stop
    var timestamp: Date
    var visible: Bool
    var arrivalTime: String
    var first: Bool
    var last: Bool

    public init(stop: BusRoute.Stop,
                arrivalTime: String,
                timestamp: Date,
                visible: Bool,
                first: Bool,
                last: Bool) {
        self.stop = stop
        self.timestamp = timestamp
        self.visible = visible
        self.first = first
        self.last = last
        self.arrivalTime = arrivalTime
        if Int(self.arrivalTime) ?? 0 > 60 {
            let hour = (Int(self.arrivalTime) ?? 0) / 60
            let minutes = (Int(self.arrivalTime) ?? 0) % 60
            self.arrivalTime = "\(hour)h\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        }
    }

    enum CodingKeys: String, CodingKey {
        case stop
        case timestamp
        case visible
        case arrivalTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stop = try container.decode(BusRoute.Stop.self, forKey: .stop)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        let visible = try container.decode(Bool.self, forKey: .visible)
        let arrivalTime: String
        do {
            arrivalTime = try container.decode(String.self, forKey: .arrivalTime)
        } catch {
            arrivalTime = ""
        }
        let first = false
        let last = false

        self.init(stop: stop,
                  arrivalTime: arrivalTime,
                  timestamp: timestamp,
                  visible: visible,
                  first: first,
                  last: last)
    }
}
