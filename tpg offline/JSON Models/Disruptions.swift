//
//  Disruptions.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 18/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import Foundation

struct DisruptionsGroup: Decodable {
    var disruptions: [String: [Disruption]] = [:]

    public init(disruptions: [String: [Disruption]] = [:]) {
        self.disruptions = disruptions
    }

    enum CodingKeys: String, CodingKey {
        case disruptions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let disruptions = try container.decode([Disruption].self, forKey: .disruptions)
        var a: [String: [Disruption]] = [:]
        for disruption in disruptions {
            if a.index(forKey: disruption.line) == nil {
                a[disruption.line] = []
            }
            a[disruption.line]?.append(disruption)
        }

        self.init(disruptions: a)
    }
}

struct Disruption: Decodable {

    var place: String
    var consequence: String
    var nature: String
    var line: String

    public init(place: String, consequence: String, nature: String, line: String) {
        self.place = place
        self.consequence = consequence
        self.nature = nature
        self.line = line

        if String(nature.suffix(1)) == "\n" {
            self.nature = String(self.nature.prefix(nature.count - 1))
        }

        if String(consequence.suffix(1)) == "\n" {
            self.consequence = String(self.consequence.prefix(consequence.count - 1))
        }
    }

    enum CodingKeys: String, CodingKey {
        case place
        case consequence
        case nature
        case line = "lineCode"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let place = try container.decode(String.self, forKey: .place)
        let consequence = try container.decode(String.self, forKey: .consequence)
        let nature = try container.decode(String.self, forKey: .nature)
        let line = try container.decode(String.self, forKey: .line)

        self.init(place: place, consequence: consequence, nature: nature, line: line)
    }
}
