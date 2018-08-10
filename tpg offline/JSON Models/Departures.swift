//
//  Departure.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 10/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit

struct DeparturesGroup: Decodable {
  var departures: [Departure]
  var lines: [String]

  public init(departures: [Departure]) {
    self.departures = departures.filter({
      $0.leftTime != "no more" && $0.leftTime != "-1"
    })
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
    var departures = try container.decode([Departure].self, forKey: .departures)
    if let options = decoder.userInfo[DeparturesOptions.key] as? DeparturesOptions,
      options.networkStatus == .offline {
      departures = departures.filter({ $0.leftTime != "-1" })
    }
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

  enum Reliability: String, Codable {
    case reliable = "F"
    case theoretical = "T"
  }

  enum ReducedMobilityAccessibility {
    case accessible
    case inaccessible
  }

  var line: Line
  var code: Int
  var leftTime: String
  var timestamp: String
  var wifi: Bool
  var reliability: Reliability
  var dateCompenents: DateComponents?
  var reducedMobilityAccessibility: ReducedMobilityAccessibility
  var platform: String?
  var vehiculeNo: Int
  var offline: Bool

  public init(line: Line,
              code: Int,
              leftTime: String,
              timestamp: String,
              dateCompenents: DateComponents?,
              wifi: Bool,
              reliability: Reliability,
              reducedMobilityAccessibility: ReducedMobilityAccessibility,
              platform: String?,
              vehiculeNo: Int,
              offline: Bool) {
    self.line = line
    self.code = code
    self.leftTime = leftTime
    self.timestamp = timestamp
    self.dateCompenents = dateCompenents
    self.wifi = wifi
    self.reliability = reliability
    self.reducedMobilityAccessibility = reducedMobilityAccessibility
    self.platform = platform
    self.vehiculeNo = vehiculeNo
    self.offline = offline

    if self.leftTime == "" {
      self.calculateLeftTime()
    }
  }

  enum CodingKeys: String, CodingKey {
    case line
    case directionOffline = "direction"
    case code = "departureCode"
    case leftTime
    case timestamp
    case vehiculeNo
    case reliability
    case characteristics
    case platform
    case wifi
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let options = decoder.userInfo[DeparturesOptions.key] as? DeparturesOptions {
      switch options.networkStatus {
      case .online:
        let line = try container.decode(Departure.Line.self, forKey: .line)
        let code = (try? container.decode(Int.self, forKey: .code)) ?? -1
        let leftTime = (try? container.decode(String.self, forKey: .leftTime)) ?? ""
        let timestamp =
          (try? container.decode(String.self, forKey: .timestamp)) ?? ""
        let vehiculeNo = (try? container.decode(Int.self, forKey: .vehiculeNo)) ?? -1
        let wifi = (try? container.decode(Bool.self, forKey: .wifi)) ?? false
        let reliability =
          (try? container.decode(Reliability.self, forKey: .reliability)) ?? .reliable
        let reducedMobilityAccessibility: ReducedMobilityAccessibility =
          ((try? container.decode(String.self, forKey: .characteristics)) ?? "PMR")
            == "PMR" ? .accessible : .inaccessible
        let platform = try? container.decode(String.self, forKey: .platform)
        self.init(line: line,
                  code: code,
                  leftTime: leftTime,
                  timestamp: timestamp,
                  dateCompenents: nil,
                  wifi: wifi,
                  reliability: reliability,
                  reducedMobilityAccessibility: reducedMobilityAccessibility,
                  platform: platform,
                  vehiculeNo: vehiculeNo,
                  offline: false)
      case .offline:
        let lineString = try container.decode(String.self, forKey: .line)
        let destinationId =
          try container.decode(String.self, forKey: .directionOffline)
        let destination =
          App.stops.filter({ $0.sbbId == destinationId }).first?.name ?? destinationId
        let line = Departure.Line(code: lineString,
                                  destination: destination,
                                  destinationCode: "")
        let timestamp = (try container.decode(String.self, forKey: .timestamp)) + "+0200"
        self.init(line: line,
                  code: -1,
                  leftTime: "",
                  timestamp: timestamp,
                  dateCompenents: nil,
                  wifi: false,
                  reliability: .reliable,
                  reducedMobilityAccessibility: .accessible,
                  platform: nil,
                  vehiculeNo: -1,
                  offline: true)

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
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let time = dateFormatter.date(from: timestamp)
      var timestampDateComponents: DateComponents = Calendar.current.dateComponents([
        .year,
        .month,
        .day,
        .hour,
        .minute,
        .second], from: time ?? Date())

      let now = Calendar.current.dateComponents([.year,
                                                 .month,
                                                 .day,
                                                 .hour,
                                                 .minute,
                                                 .second], from: Date())
      timestampDateComponents.year = now.year
      timestampDateComponents.month = now.month
      timestampDateComponents.day = now.day
      timestampDateComponents.calendar = Calendar.current

      dateCompenents = timestampDateComponents

      if Calendar.current.date(from: timestampDateComponents)!.compare(Date())
        == .orderedAscending {
        self.leftTime = "-1"
      } else {
        self.leftTime =
          String(Int(Calendar.current.date(from: timestampDateComponents)!
            .timeIntervalSinceNow / 60))
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
  static let key =
    CodingUserInfoKey(rawValue: "com.dacostafaro.tpgoffline.departuresOptions")!
}
