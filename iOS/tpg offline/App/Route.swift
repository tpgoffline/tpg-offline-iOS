//
//  Route.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

internal class Route {
    var from: String!
    var to: String! // swiftlint:disable:this identifier_name
    var duration: String!
    var departureTimestamp: Int!
    var arrivalTimestamp: Int!
    var connections: [RoutesConnections]!

    // swiftlint:disable identifier_name
    init(from: String,
         to: String,
         duration: String,
         departureTimestamp: Int!,
         arrivalTimestamp: Int!,
         connections: [RoutesConnections]) {
        self.from = from
        self.to = to
        self.duration = duration
        self.departureTimestamp = departureTimestamp
        self.arrivalTimestamp = arrivalTimestamp
        self.connections = connections
    }
    init() {
        self.from = ""
        self.to = ""
        self.duration = ""
        self.departureTimestamp = 0
        self.arrivalTimestamp = 0
        self.connections = []
    }

    func describe() -> String {
        return "[from: \(from), to: \(to), duration: \(duration), departuresTimestamp: \(departureTimestamp), arrivalTimestamp: \(arrivalTimestamp), connections: \(connections)]"
    }
}
