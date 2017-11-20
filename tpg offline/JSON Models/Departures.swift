//
//  Departure.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 10/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

struct DeparturesGroup: Decodable {
    var departures: [Departure]
    var lines: [String]

    public init(departures: [Departure]) {
        self.departures = departures.filter({ $0.leftTime != "no more" && $0.leftTime != "-1" })
        self.lines = departures.map({$0.line.code}).uniqueElements.sorted(by: {
            if let a = Int($0), let b = Int($1) {
                return a < b
            } else { return $0 < $1 }})
    }

    enum CodingKeys: String, CodingKey {
        case departures
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let departures = try container.decode([Departure].self, forKey: .departures)
        self.init(departures: departures)
    }
}

struct Departure: Decodable {
    struct Line: Codable {
        let code: String
        let destination: String
        let destinationCode: String

        public init(code: String, destination: String, destinationCode: String) {
            self.code = code
            self.destination = destination
            self.destinationCode = destinationCode
        }

        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case code = "lineCode"
            case destination = "destinationName"
            case destinationCode
        }
    }

    var line: Line
    var code: Int
    var leftTime: String
    var timestamp: String
    var dateCompenents: DateComponents?

    public init(line: Line, code: Int, leftTime: String, timestamp: String, dateCompenents: DateComponents?) {
        self.line = line
        self.code = code
        self.leftTime = leftTime
        self.timestamp = timestamp
        self.dateCompenents = dateCompenents

        if self.leftTime == "" {
            self.calculateLeftTime()
        }
    }

    enum CodingKeys: String, CodingKey {
        case lineOnline = "line"
        case lineOffline = "ligne"
        case destinationOffline = "destination"
        case code = "departureCode"
        case leftTime
        case timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let options = decoder.userInfo[DeparturesOptions.key] as? DeparturesOptions {
            switch options.networkStatus {
            case .online:
                let line = try container.decode(Departure.Line.self, forKey: .lineOnline)
                let code = (try? container.decode(Int.self, forKey: .code)) ?? -1
                let leftTime = (try? container.decode(String.self, forKey: .leftTime)) ?? ""
                let timestamp = (try? container.decode(String.self, forKey: .timestamp)) ?? ""
                self.init(line: line, code: code, leftTime: leftTime, timestamp: timestamp, dateCompenents: nil)
            case .offline:
                let lineString = try container.decode(String.self, forKey: .lineOffline)
                let destination = try container.decode(String.self, forKey: .destinationOffline)
                let line = Departure.Line(code: lineString, destination: destination, destinationCode: "")
                let timestamp = try container.decode(String.self, forKey: .timestamp)
                self.init(line: line, code: -1, leftTime: "", timestamp: timestamp, dateCompenents: nil)
            }
        } else {
            fatalError("You need to set network status with DeparturesOptions")
        }
    }

    mutating func calculateLeftTime() {
        if self.timestamp == "" {
            self.leftTime = "-1"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            let time = dateFormatter.date(from: timestamp)
            var timestampDateComponents: DateComponents = Calendar.current.dateComponents([
                .year,
                .month,
                .day,
                .hour,
                .minute,
                .second], from: time ?? Date())

            let now = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            timestampDateComponents.year = now.year
            timestampDateComponents.month = now.month
            timestampDateComponents.day = now.day
            timestampDateComponents.calendar = Calendar.current
            timestampDateComponents.timeZone = now.timeZone

            dateCompenents = timestampDateComponents

            if Calendar.current.date(from: timestampDateComponents)!.compare(Date()) == .orderedAscending {
                self.leftTime = "-1"
            } else {
                self.leftTime =
                    String(Int(Calendar.current.date(from: timestampDateComponents)!.timeIntervalSinceNow / 60))
            }
        }
    }
}

struct DeparturesOptions {
    enum NetworkStatusEnum {
        case online
        case offline
    }

    var networkStatus = NetworkStatusEnum.online
    static let key = CodingUserInfoKey(rawValue: "com.dacostafaro.tpgoffline.departuresOptions")!
}
