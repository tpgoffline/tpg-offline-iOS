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
