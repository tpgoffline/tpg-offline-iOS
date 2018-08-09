//
//  URL.swift
//  tpg offline
//
//  Created by レミー on 11/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

extension URL {
  static func departures(with stopCode: String) -> String {
    return "https://api.tpgoffline.com/departures/\(stopCode)?key=\(API.tpg)"
  }
  static func connectionsMap(stopCode: String) -> String {
    return "https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/Connections%20Maps/\(stopCode).jpg"
  }
  static var monitoring: String {
    return "https://api.tpgoffline.com/disruptionsmonitoring/\(App.apnsToken)"
  }
  static var smartReminders: String {
    return "https://api.tpgoffline.com/reminders/\(App.apnsToken)"
  }
  static let thermometer = "https://prod.ivtr-od.tpg.ch/v1/GetThermometer.json"
  static let offlineDeparturesMD5 = "https://raw.githubusercontent.com/tpgoffline/tpgoffline-data/master/departures.json.md5"
  static let offlineDepartures = "https://raw.githubusercontent.com/tpgoffline/tpgoffline-data/master/departures.json"
  static let stopsMD5 = "https://raw.githubusercontent.com/tpgoffline/tpgoffline-data/master/stops.json.md5"
  static let linesMD5 = "https://raw.githubusercontent.com/tpgoffline/tpgoffline-data/master/lines.json.md5"
  static let stops = "https://raw.githubusercontent.com/tpgoffline/tpgoffline-data/master/stops.json"
  static let lines = "https://raw.githubusercontent.com/tpgoffline/tpgoffline-data/master/lines.json"
  static let googleMapsGeocode = "https://maps.googleapis.com/maps/api/geocode/json"
  static let allNextDepartures = "https://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json"
  static let disruptions = "https://api.tpgoffline.com/disruptions"
  static let replacementNames = "https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/replacementsNames.json"
  static let connections = "https://transport.opendata.ch/v1/connections"
  static let asmartcode = "https://asmartcode.com"
  static let dacostafaro = "http://dacostafaro.com"
  static let snotpg = "https://www.snotpg.ch/site/"
  static let openData = "http://www.tpg.ch/web/open-data/"
  static let gtfs = "https://opendata.swiss/fr/dataset/timetable-2018-gtfs"
  static let transportApi = "https://transport.opendata.ch"
  static let alamofire = "https://github.com/Alamofire/Alamofire"
  static let fabric = "https://get.fabric.io/"
  static let github = "https://github.com/tpgoffline/tpg-offline-iOS"
  static let privacyStatement = "https://wiki.tpgoffline.com/index.php?title=D%C3%A9claration_de_confidentialit%C3%A9_-_App_iOS/en".localized
  static var mapUrl: URL {
    return (App.darkMode ? URL(string: "mapbox://styles/remydcf/cjkl5f9tm0yyi2smonz4fr2go") : URL(string: "mapbox://styles/remydcf/cjkl5fqlw616i2rmwvlv75j98"))!
  }
  static var mapLight: URL {
    return URL(string: "mapbox://styles/remydcf/cjkl5fqlw616i2rmwvlv75j98")!
  }
  static var mapDark: URL {
    return URL(string: "mapbox://styles/remydcf/cjkl5f9tm0yyi2smonz4fr2go")!
  }
}
