//
//  SplashScreenViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 24/10/2016.
//  Copyright © 2016 Rémy DA COSTA FARO. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import FirebaseAnalytics
import SwiftyJSON

enum ShortcutIdentifier: String {
    case departures = "departures"
    case incidents = "incidents"
    case routes = "routes"
    case maps = "maps"

    init?(fullIdentifier: String) {
        guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }

    func getNumberOfTab() -> Int? {
        switch self {
        case .departures:
            return 0
        case .incidents:
            return 1
        case .routes:
            return 2
        case .maps:
            return 3
        }
    }
}

struct BeforeStarting {
    static var predefinedTabBarItem: Int = -1
}

class SplashScreenViewController: UIViewController {

    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            print("Debug mode")
        #else
            print("Release mode")
        #endif

        WatchSessionManager.sharedManager.startSession()

        getDefaults()

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startTpgOffline", sender: nil)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startTpgOffline" {
            if let destination = segue.destination as? UITabBarController {
                self.setUpTabBar(destination)
            }
        }
    }

    func setUpTabBar(_ tabBarController: UITabBarController!) {
        if AppValues.primaryColor.contrast == .white {
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: AppValues.textColor], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: AppValues.textColor], for: UIControlState())
        }

        tabBarController.tabBar.tintColor = AppValues.textColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 49))

        tabBarController.tabBar.barTintColor = AppValues.primaryColor
        view.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)

        if AppValues.primaryColor.contrast == .white {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            tabBarController.tabBar.selectionIndicatorImage = image
        }

        if AppValues.primaryColor.contrast == .white {
            var iconImage = #imageLiteral(resourceName: "clock").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![0].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![0].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "warning").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![1].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![1].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "routes").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![2].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![2].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "map").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![3].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![3].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "cog").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![4].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![4].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)
        } else {
            var iconImage = #imageLiteral(resourceName: "clock").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![0].image = iconImage
            tabBarController!.tabBar.items![0].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "warning").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![1].image = iconImage
            tabBarController!.tabBar.items![1].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "routes").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![2].image = iconImage
            tabBarController!.tabBar.items![2].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "map").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![3].image = iconImage
            tabBarController!.tabBar.items![3].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "cog").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![4].image = iconImage
            tabBarController!.tabBar.items![4].selectedImage = iconImage
        }

        if !self.defaults.bool(forKey: "tutorial") && !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            tabBarController.selectedIndex = 4
        } else {
            tabBarController.selectedIndex = self.defaults.integer(forKey: "selectedTabBar")
        }

        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/Departs/infos.json", method: .get).responseData { (request) in
            if request.result.isSuccess {
                do {
                    let json = try JSON(data: request.data!)
                    if json["version"].intValue != self.defaults.integer(forKey: UserDefaultsKeys.offlineDeparturesVersion.rawValue) {
                        AppValues.needUpdateDepartures = true
                        tabBarController.selectedIndex = 4
                    }
                } catch {

                }
            }
        }
    }

    func getDefaults() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.dacostafaro.tpgoffline.gcd.splashscreen", attributes: .concurrent, target: .global())

        group.enter()
        queue.async(group: group) {
            do {
                let data: Data!
                if let data2 = self.defaults.data(forKey: UserDefaultsKeys.stops.rawValue) {
                    data = data2
                } else {
                    data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "stops", ofType: "json")!))
                }
                let arrets = try JSON(data: data)
                for (_, subJson) in arrets["stops"] {
                    AppValues.stopCodeToStopItem[subJson["stopCode"].string!] = subJson["stopName"].string!
                    AppValues.idTransportAPIToTpgStopName[Int(subJson["idTransportAPI"].stringValue)!] = subJson["stopName"].string!
                    AppValues.nameTransportAPIToTpgStopName[subJson["nameTransportAPI"].stringValue] = subJson["stopName"].string!
                    AppValues.stops[subJson["stopName"].string!] = Stop(
                        fullName: subJson["stopName"].string!,
                        title: subJson["titleName"].string!,
                        subTitle: subJson["subTitleName"].string!,
                        stopCode: subJson["stopCode"].string!,
                        location: CLLocation(
                            latitude: subJson["locationX"].double!,
                            longitude: subJson["locationY"].double!
                        ),
                        transportAPIiD: subJson["idTransportAPI"].string!,
                        connections: subJson["connections"].arrayObject as? [String] ?? []
                    )
                    let letter = String(subJson["stopName"].string![subJson["stopName"].string!.startIndex]).uppercased()
                    if AppValues.stopsABC[letter] == nil {
                        AppValues.stopsABC[letter] = []
                    }
                    AppValues.stopsABC[letter]!.append(subJson["stopName"].string!)
                }

                for (key, stringArray) in AppValues.stopsABC {
                    AppValues.stopsABC[key] = stringArray.sorted()
                }

                AppValues.stopsKeys = [String](AppValues.stops.keys)
                AppValues.stopsKeys.sort(by: { (string1, string2) -> Bool in
                    let stringA = String((AppValues.stops[string1]?.title)! + (AppValues.stops[string1]?.subTitle)!)
                    let stringB = String((AppValues.stops[string2]?.title)! + (AppValues.stops[string2]?.subTitle)!)
                    if stringA!.lowercased() < stringB!.lowercased() {
                        return true
                    }
                    return false
                })
                group.leave()
            } catch {

            }
        }

        group.enter()
        queue.async(group: group) {
            if self.defaults.object(forKey: "favoritesStops") == nil {
                AppValues.favoritesStops = [:]
            } else {
                let decoded  = self.defaults.object(forKey: "favoritesStops")
                guard let data = decoded as? Data else {
                    return
                }
                let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String:Stop]
                AppValues.favoritesStops = unarchivedData
                for (_, y) in AppValues.favoritesStops {
                    AppValues.fullNameFavoritesStops.append(y.fullName)
                }
                AppValues.fullNameFavoritesStops.sort(by: { (value1, value2) -> Bool in
                    if value1.lowercased() < value2.lowercased() {
                        return true
                    } else {
                        return false
                    }
                })
            }
            group.leave()
        }

        group.enter()
        queue.async(group: group) {
            do {
                let colorsData: Data!
                if let data2 = self.defaults.data(forKey: UserDefaultsKeys.colorLines.rawValue) {
                    colorsData = data2
                } else {
                    colorsData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "colorLines", ofType: "json")!))
                }
                let colors = try JSON(data: colorsData!)
                for (_, j) in colors["colors"] {
                    AppValues.linesBackgroundColor[j["lineCode"].string!] = UIColor(hexString: j["background"].string!)
                    AppValues.linesColor[j["lineCode"].string!] = UIColor(hexString: j["text"].string!)
                }
                group.leave()
            } catch {}
        }

        group.enter()
        queue.async(group: group) {
            var decoded = self.defaults.object(forKey: UserDefaultsKeys.favoritesRoutes.rawValue)
            if decoded == nil {
                decoded = []
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                self.defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesRoutes.rawValue)
            } else {
                guard let data = decoded as? Data else {
                    return
                }
                guard let tempUnarchivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Any]] else {
                    AppValues.favoritesRoutes = []
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                    self.defaults.set(encodedData, forKey: UserDefaultsKeys.textColor.rawValue)
                    return
                }
                if !tempUnarchivedData.isEmpty {
                    let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Stop]]
                    AppValues.favoritesRoutes = unarchivedData
                } else {
                    AppValues.favoritesRoutes = []
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                    self.defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesRoutes.rawValue)
                }
            }

            if self.defaults.colorForKey(UserDefaultsKeys.primaryColor.rawValue) == nil {
                self.defaults.setColor(AppValues.primaryColor, forKey: UserDefaultsKeys.primaryColor.rawValue)
            } else {
                AppValues.primaryColor = self.defaults.colorForKey(UserDefaultsKeys.primaryColor.rawValue)
            }

            if AppValues.primaryColor.contrast != .white && AppValues.primaryColor != .white {
                AppValues.primaryColor = .white
                self.defaults.setColor(.white, forKey: UserDefaultsKeys.primaryColor.rawValue)
            }

            if self.defaults.colorForKey(UserDefaultsKeys.textColor.rawValue) == nil {
                self.defaults.setColor(AppValues.textColor, forKey: UserDefaultsKeys.textColor.rawValue)
            } else {
                AppValues.textColor = self.defaults.colorForKey(UserDefaultsKeys.textColor.rawValue)
            }

            #if DEBUG
                print("\(AppValues.primaryColor.hexValue) \(AppValues.textColor.hexValue)")
            #else
                FIRAnalytics.setUserPropertyString("\(AppValues.primaryColor.hexValue) \(AppValues.textColor.hexValue)", forName: "theme")
            #endif

            if AppValues.primaryColor.contrast == .white {
                UIApplication.shared.statusBarStyle = .lightContent
            } else {
                UIApplication.shared.statusBarStyle = .default
            }
            group.leave()
        }

        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/tpg%20offline/Project%20Requirements/stops.json", method: .get).responseData { (request) in
            if request.result.isSuccess {
                self.defaults.set(request.data!, forKey: UserDefaultsKeys.stops.rawValue)
            }
        }

        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/tpg%20offline/Project%20Requirements/colorLines.json", method: .get).responseData { (request) in
            if request.result.isSuccess {
                self.defaults.set(request.data!, forKey: UserDefaultsKeys.colorLines.rawValue)
            }
        }

        group.wait()
    }
}
