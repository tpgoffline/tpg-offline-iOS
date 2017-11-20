//
//  App.swift
//  tpg offline
//
//  Created by Remy on 24/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import WatchConnectivity

struct App {
    #if os(iOS)
    private static var watchSessionManager = WatchSessionManager.shared
    #endif
    static var stops: [Stop] = []
    static var sortedStops: [String: [String]] = [:]
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
                UserDefaults.standard.data(forKey: #function) ?? "".data(using: .utf8)!)
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
            return (UserDefaults.standard.dictionary(forKey: #function) as? [String: String]) ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            #if os(iOS)
                watchSessionManager.sync()
            #endif
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

    static var defaultTab: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    static var linesColor: [LineColor] = [LineColor(line: "1", color: UIColor(hexString: "5a1e82")!), LineColor(line: "2", color: UIColor(hexString: "cccc33")!), LineColor(line: "3", color: UIColor(hexString: "CC3399")!), LineColor(line: "4", color: UIColor(hexString: "CC0033")!), LineColor(line: "5", color: UIColor(hexString: "0099FF")!), LineColor(line: "6", color: UIColor(hexString: "0099CC")!), LineColor(line: "7", color: UIColor(hexString: "009933")!), LineColor(line: "8", color: UIColor(hexString: "993333")!), LineColor(line: "9", color: UIColor(hexString: "CC0033")!), LineColor(line: "10", color: UIColor(hexString: "32781e")!), LineColor(line: "11", color: UIColor(hexString: "993399")!), LineColor(line: "12", color: UIColor(hexString: "ff9900")!), LineColor(line: "14", color: UIColor(hexString: "5a1e82")!), LineColor(line: "15", color: UIColor(hexString: "993333")!), LineColor(line: "18", color: UIColor(hexString: "cc3399")!), LineColor(line: "19", color: UIColor(hexString: "ffcc00")!), LineColor(line: "21", color: UIColor(hexString: "663333")!), LineColor(line: "22", color: UIColor(hexString: "5a1e82")!), LineColor(line: "23", color: UIColor(hexString: "CC3399")!), LineColor(line: "25", color: UIColor(hexString: "993333")!), LineColor(line: "28", color: UIColor(hexString: "FFCC00")!), LineColor(line: "31", color: UIColor(hexString: "009999")!), LineColor(line: "32", color: UIColor(hexString: "666666")!), LineColor(line: "33", color: UIColor(hexString: "009999")!), LineColor(line: "34", color: UIColor(hexString: "99CCCC")!), LineColor(line: "35", color: UIColor(hexString: "666666")!), LineColor(line: "36", color: UIColor(hexString: "666666")!), LineColor(line: "41", color: UIColor(hexString: "009999")!), LineColor(line: "42", color: UIColor(hexString: "99CCCC")!), LineColor(line: "43", color: UIColor(hexString: "99CCCC")!), LineColor(line: "44", color: UIColor(hexString: "009999")!), LineColor(line: "45", color: UIColor(hexString: "99CCCC")!), LineColor(line: "46", color: UIColor(hexString: "009999")!), LineColor(line: "47", color: UIColor(hexString: "00B0A4")!), LineColor(line: "51", color: UIColor(hexString: "009999")!), LineColor(line: "53", color: UIColor(hexString: "99CCCC")!), LineColor(line: "54", color: UIColor(hexString: "009999")!), LineColor(line: "56", color: UIColor(hexString: "009999")!), LineColor(line: "57", color: UIColor(hexString: "99CCCC")!), LineColor(line: "61", color: UIColor(hexString: "FF9BAA")!), LineColor(line: "A", color: UIColor(hexString: "FF6600")!), LineColor(line: "B", color: UIColor(hexString: "FF6600")!), LineColor(line: "C", color: UIColor(hexString: "FF6600")!), LineColor(line: "D", color: UIColor(hexString: "FF9999")!), LineColor(line: "DN", color: UIColor(hexString: "FF9BAA")!), LineColor(line: "E", color: UIColor(hexString: "FF6600")!), LineColor(line: "F", color: UIColor(hexString: "FF9999")!), LineColor(line: "G", color: UIColor(hexString: "FF9999")!), LineColor(line: "J", color: UIColor(hexString: "FF6600")!), LineColor(line: "K", color: UIColor(hexString: "FF9999")!), LineColor(line: "L", color: UIColor(hexString: "FF6600")!), LineColor(line: "M", color: UIColor(hexString: "FF9BAA")!), LineColor(line: "N", color: UIColor(hexString: "FF9999")!), LineColor(line: "NA", color: UIColor(hexString: "5A1E82")!), LineColor(line: "NC", color: UIColor(hexString: "663399")!), LineColor(line: "ND", color: UIColor(hexString: "993333")!), LineColor(line: "NE", color: UIColor(hexString: "cc3399")!), LineColor(line: "NJ", color: UIColor(hexString: "cccc33")!), LineColor(line: "NK", color: UIColor(hexString: "ff9900")!), LineColor(line: "NM", color: UIColor(hexString: "ff9900")!), LineColor(line: "NO", color: UIColor(hexString: "B82F89")!), LineColor(line: "NP", color: UIColor(hexString: "009999")!), LineColor(line: "NS", color: UIColor(hexString: "008CBE")!), LineColor(line: "NT", color: UIColor(hexString: "00ACE7")!), LineColor(line: "NV", color: UIColor(hexString: "00ACE7")!), LineColor(line: "O", color: UIColor(hexString: "FF9BAA")!), LineColor(line: "P", color: UIColor(hexString: "003399")!), LineColor(line: "S", color: UIColor(hexString: "003399")!), LineColor(line: "T", color: UIColor(hexString: "FF9BAA")!), LineColor(line: "TO", color: UIColor(hexString: "E2001D")!), LineColor(line: "TT", color: UIColor(hexString: "FD0000")!), LineColor(line: "U", color: UIColor(hexString: "003399")!), LineColor(line: "V", color: UIColor(hexString: "FF6600")!), LineColor(line: "W", color: UIColor(hexString: "003399")!), LineColor(line: "X", color: UIColor(hexString: "003399")!), LineColor(line: "Y", color: UIColor(hexString: "FF9999")!), LineColor(line: "Z", color: UIColor(hexString: "FF9999")!), LineColor(line: "80", color: UIColor(hexString: "000000")!), LineColor(line: "81", color: UIColor(hexString: "000000")!), LineColor(line: "82", color: UIColor(hexString: "000000")!), LineColor(line: "83", color: UIColor(hexString: "000000")!), LineColor(line: "84", color: UIColor(hexString: "000000")!), LineColor(line: "85", color: UIColor(hexString: "000000")!), LineColor(line: "86", color: UIColor(hexString: "000000")!), LineColor(line: "92", color: UIColor(hexString: "000000")!), LineColor(line: "93", color: UIColor(hexString: "000000")!), LineColor(line: "94", color: UIColor(hexString: "000000")!), LineColor(line: "96", color: UIColor(hexString: "000000")!), LineColor(line: "97", color: UIColor(hexString: "000000")!)] // swiftlint:disable:this line_length

    static func color(for lineCode: String) -> UIColor {
        var color: UIColor = App.linesColor.filter({ $0.line == lineCode })[safe: 0]?.color ?? .black
        if color.contrast != .white {
            color = color.darken(by: 0.2)!
        }
        return color
    }

    @discardableResult static func loadStops() -> Bool {
        do {
            let data: Data
            if let dataA = UserDefaults.standard.data(forKey: "stops.json") {
                data = dataA
            } else {
                do {
                    data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "stops", ofType: "json")!))
                } catch {
                    print("Can't load stops")
                    abort()
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
            print("error")
            return false
        }
    }
    static var textColor = #colorLiteral(red: 0.2392156863, green: 0.1960784314, blue: 0.1843137255, alpha: 1)
}
