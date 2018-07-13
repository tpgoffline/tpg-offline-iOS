//
//  App.swift
//  tpg offline
//
//  Created by Remy on 24/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import WatchConnectivity
#if os(iOS)
import Crashlytics
import Solar
import CoreLocation
#endif

struct App {
  #if os(iOS)
  private static var watchSessionManager = WatchSessionManager.shared
  #endif
  static var lines: [Line] = []
  static var stops: [Stop] = []
  static var sortedStops: [String: [String]] = [:]
  static var stopsKeys: [String] {
    get {
      guard let a =
        (UserDefaults.standard.array(forKey: #function) as? [String]) else {
          let keys = ["location", "favorites"] + App.sortedStops.keys.sorted()
          UserDefaults.standard.set(keys, forKey: #function)
          return ["location", "favorites"] + App.sortedStops.keys.sorted()
      }
      return a
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  static var favoritesStops: [Int] {
    get {
      return (UserDefaults.standard.object(forKey: #function) as? [Int]) ?? []
    } set {
      UserDefaults.standard.set(newValue, forKey: #function)
      #if os(iOS)
      watchSessionManager.sync()
      #endif
    }
  }
  static var favoritesRoutes: [Route] {
    get {
      let jsonDecoder = JSONDecoder()
      let jsonData = try? jsonDecoder.decode([Route].self, from:
        UserDefaults.standard.data(forKey: #function) ?? ""
          .data(using: .utf8)!)
      return jsonData ?? []
    } set {
      let jsonEncoder = JSONEncoder()
      let jsonData = try? jsonEncoder.encode(newValue)
      UserDefaults.standard.set(jsonData, forKey: #function)
      #if os(iOS)
      watchSessionManager.sync()
      #endif
    }
  }
  static var replacementsNames: [String: String] {
    get {
      return (UserDefaults.standard.dictionary(forKey: #function)
        as? [String: String]) ?? [:]
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
      #if os(iOS)
      watchSessionManager.sync()
      #endif
    }
  }
  
  #if os(iOS)
  static var sunriseSunsetManager = Solar(coordinate:
    CLLocationCoordinate2D(latitude: 46.204391, longitude: 6.143158))
  #endif
  
  static var apnsToken: String = "" {
    didSet {
      #if os(iOS)
      watchSessionManager.sync()
      #endif
    }
  }
  
  static var darkMode: Bool {
    get {
      return (UserDefaults.standard.bool(forKey: #function))
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
      #if os(iOS)
      ColorModeManager.shared.updateColorMode()
      #endif
    }
  }
  
  #if os(iOS)
  static var automaticDarkMode: Bool {
    get {
      return (UserDefaults.standard.bool(forKey: #function))
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  #endif
  
  static var smartReminders: Bool {
    get {
      return (UserDefaults.standard.bool(forKey: #function))
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
      #if os(iOS)
      watchSessionManager.sync()
      #endif
    }
  }
  
  static var disableForceSmartReminders: Bool {
    get {
      return (UserDefaults.standard.bool(forKey: #function))
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  
  static var automaticDeparturesDownload: Bool {
    // Here, get and set are inverted to set this value to true by default
    get {
      return !(UserDefaults.standard.bool(forKey: #function))
    }
    set {
      UserDefaults.standard.set(!newValue, forKey: #function)
    }
  }
  
  static var indexedStops: [Int] {
    get {
      return (UserDefaults.standard.array(forKey: #function) as? [Int]) ?? []
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  
  static var favoritesLines: [String] {
    get {
      return (UserDefaults.standard.array(forKey: #function) as? [String])
        ?? []
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  
  static var filterFavoritesLines: Bool {
    get {
      return UserDefaults.standard.bool(forKey: #function)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  
  static var defaultTab: Int {
    get {
      return UserDefaults.standard.integer(forKey: #function)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }
  
  static var tpgLinesColor: [LineColor] =
    [LineColor(line: "1", color: UIColor(hexString: "5a1e82")!),
     LineColor(line: "2", color: UIColor(hexString: "cccc33")!),
     LineColor(line: "3", color: UIColor(hexString: "CC3399")!),
     LineColor(line: "4", color: UIColor(hexString: "CC0033")!),
     LineColor(line: "5", color: UIColor(hexString: "0099FF")!),
     LineColor(line: "6", color: UIColor(hexString: "0099CC")!),
     LineColor(line: "7", color: UIColor(hexString: "009933")!),
     LineColor(line: "8", color: UIColor(hexString: "993333")!),
     LineColor(line: "9", color: UIColor(hexString: "CC0033")!),
     LineColor(line: "10", color: UIColor(hexString: "32781e")!),
     LineColor(line: "11", color: UIColor(hexString: "993399")!),
     LineColor(line: "12", color: UIColor(hexString: "ff9900")!),
     LineColor(line: "14", color: UIColor(hexString: "5a1e82")!),
     LineColor(line: "15", color: UIColor(hexString: "993333")!),
     LineColor(line: "18", color: UIColor(hexString: "cc3399")!),
     LineColor(line: "19", color: UIColor(hexString: "ffcc00")!),
     LineColor(line: "21", color: UIColor(hexString: "663333")!),
     LineColor(line: "22", color: UIColor(hexString: "5a1e82")!),
     LineColor(line: "23", color: UIColor(hexString: "CC3399")!),
     LineColor(line: "25", color: UIColor(hexString: "993333")!),
     LineColor(line: "28", color: UIColor(hexString: "FFCC00")!),
     LineColor(line: "31", color: UIColor(hexString: "009999")!),
     LineColor(line: "32", color: UIColor(hexString: "666666")!),
     LineColor(line: "33", color: UIColor(hexString: "009999")!),
     LineColor(line: "34", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "35", color: UIColor(hexString: "666666")!),
     LineColor(line: "36", color: UIColor(hexString: "666666")!),
     LineColor(line: "41", color: UIColor(hexString: "009999")!),
     LineColor(line: "42", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "43", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "44", color: UIColor(hexString: "009999")!),
     LineColor(line: "45", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "46", color: UIColor(hexString: "009999")!),
     LineColor(line: "47", color: UIColor(hexString: "00B0A4")!),
     LineColor(line: "51", color: UIColor(hexString: "009999")!),
     LineColor(line: "53", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "54", color: UIColor(hexString: "009999")!),
     LineColor(line: "56", color: UIColor(hexString: "009999")!),
     LineColor(line: "57", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "61", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "A", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "B", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "C", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "D", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "DN", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "E", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "F", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "G", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "J", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "K", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "L", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "M", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "N", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "NA", color: UIColor(hexString: "5A1E82")!),
     LineColor(line: "NC", color: UIColor(hexString: "663399")!),
     LineColor(line: "ND", color: UIColor(hexString: "993333")!),
     LineColor(line: "NE", color: UIColor(hexString: "cc3399")!),
     LineColor(line: "NJ", color: UIColor(hexString: "cccc33")!),
     LineColor(line: "NK", color: UIColor(hexString: "ff9900")!),
     LineColor(line: "NM", color: UIColor(hexString: "ff9900")!),
     LineColor(line: "NO", color: UIColor(hexString: "B82F89")!),
     LineColor(line: "NP", color: UIColor(hexString: "009999")!),
     LineColor(line: "NS", color: UIColor(hexString: "008CBE")!),
     LineColor(line: "NT", color: UIColor(hexString: "00ACE7")!),
     LineColor(line: "NV", color: UIColor(hexString: "00ACE7")!),
     LineColor(line: "O", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "P", color: UIColor(hexString: "003399")!),
     LineColor(line: "S", color: UIColor(hexString: "003399")!),
     LineColor(line: "T", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "TO", color: UIColor(hexString: "E2001D")!),
     LineColor(line: "TT", color: UIColor(hexString: "FD0000")!),
     LineColor(line: "U", color: UIColor(hexString: "003399")!),
     LineColor(line: "V", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "W", color: UIColor(hexString: "003399")!),
     LineColor(line: "XA", color: UIColor(hexString: "969391")!),
     LineColor(line: "X", color: UIColor(hexString: "003399")!),
     LineColor(line: "Y", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "Z", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "80", color: UIColor(hexString: "000000")!),
     LineColor(line: "81", color: UIColor(hexString: "000000")!),
     LineColor(line: "82", color: UIColor(hexString: "000000")!),
     LineColor(line: "83", color: UIColor(hexString: "000000")!),
     LineColor(line: "84", color: UIColor(hexString: "000000")!),
     LineColor(line: "85", color: UIColor(hexString: "000000")!),
     LineColor(line: "86", color: UIColor(hexString: "000000")!),
     LineColor(line: "92", color: UIColor(hexString: "000000")!),
     LineColor(line: "93", color: UIColor(hexString: "000000")!),
     LineColor(line: "94", color: UIColor(hexString: "000000")!),
     LineColor(line: "96", color: UIColor(hexString: "000000")!),
     LineColor(line: "97", color: UIColor(hexString: "000000")!)]
  
  static var tacLinesColor: [LineColor] =
    [LineColor(line: "R", color: UIColor(hexString: "d21513")!),
     LineColor(line: "T2", color: UIColor(hexString: "2083be")!),
     LineColor(line: "3", color: UIColor(hexString: "00ad93")!),
     LineColor(line: "4", color: UIColor(hexString: "fabb60")!),
     LineColor(line: "5", color: UIColor(hexString: "ab4793")!),
     LineColor(line: "6", color: UIColor(hexString: "deda51")!),
     LineColor(line: "7", color: UIColor(hexString: "b47231")!),
     LineColor(line: "DA", color: UIColor(hexString: "40655b")!)]
  
  static func color(for lineCode: String,
                    operator stopOperator: Stop.Operator = .tpg) -> UIColor {
    var color: UIColor
    switch stopOperator {
    case .tpg:
      color = App.tpgLinesColor.filter({ $0.line == lineCode })[safe: 0]?.color
        ?? (App.darkMode ? .white : .black)
    case .tac:
      color = App.tacLinesColor.filter({ $0.line == lineCode })[safe: 0]?.color
        ?? (App.darkMode ? .white : .black)
    }
    if color.contrast != .white, !App.darkMode {
      color = color.darken(by: 0.2)
    } else if color.contrast != .black, App.darkMode {
      return color.lighten(by: 0.3)
    }
    return color
  }
  
  static var separatorColor: UIColor {
    return App.darkMode ? #colorLiteral(red: 0.2313459218, green: 0.2313911617, blue: 0.2313399315, alpha: 1) : .gray
  }
  
  @discardableResult static func loadStops(forceLocal: Bool = false) -> Bool {
    do {
      let data: Data
      if let dataA = UserDefaults.standard.data(forKey: "stops.json"), !forceLocal {
        data = dataA
      } else {
        do {
          data = try Data(contentsOf: URL(fileURLWithPath:
            Bundle.main.path(forResource: "stops", ofType: "json")!))
        } catch {
          print("Can't load stops")
          return false
        }
      }
      let decoder = JSONDecoder()
      let stops = try decoder.decode([Stop].self, from: data)
      App.stops = stops.sorted(by: { $0.name < $1.name })
      for stop in App.stops.map({ $0.name }) {
        let character = "\(stop.first!)"
        App.sortedStops[character, default: []].append(stop)
      }
      for (i, id) in App.favoritesStops.enumerated() {
        if App.stops.filter({ $0.appId == id })[safe: 0] == nil {
          App.favoritesStops.remove(at: i)
        }
      }
      return true
    } catch {
      return loadStops(forceLocal: true)
    }
  }
  static var textColor: UIColor {
    return darkMode ? .white : #colorLiteral(red: 0.2392156863, green: 0.1960784314, blue: 0.1843137255, alpha: 1)
  }
  
  static var cellBackgroundColor: UIColor {
    return darkMode ? UIColor.black.lighten(by: 0.05) : .white
  }
  
  @discardableResult static func loadLines(forceLocal: Bool = false) -> Bool {
    do {
      let data: Data
      if let dataA = UserDefaults.standard.data(forKey: "lines.json"), !forceLocal {
        data = dataA
      } else {
        do {
          data = try Data(contentsOf: URL(fileURLWithPath:
            Bundle.main.path(forResource: "lines", ofType: "json")!))
        } catch {
          print("Can't load lines")
          return false
        }
      }
      let decoder = JSONDecoder()
      let lines = try decoder.decode([Line].self, from: data)
      App.lines = lines.sorted(by: {
        if let a = Int($0.line), let b = Int($1.line) {
          return a < b
        } else { return $0.line < $1.line }})
      return true
    } catch {
      return loadLines(forceLocal: true)
    }
  }
  
  #if os(iOS)
  static func log(_ string: String) {
    CLSLogv("%@", getVaList([string]))
  }
  #endif
}
