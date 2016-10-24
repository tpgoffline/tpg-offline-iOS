//
//  AppDelegate.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import Chameleon
import Fabric
import Crashlytics
import FontAwesomeKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
            print("Debug mode")
        #else
            print("Release mode")
            Fabric.with([Crashlytics.self])
        #endif
        
        WatchSessionManager.sharedManager.startSession()
        
        getDefaults()
        setTabBar()
        
        return true
    }
    
    func executionTimeInterval(_ block: () -> ()) -> CFTimeInterval {
        let start = CACurrentMediaTime()
        block();
        let end = CACurrentMediaTime()
        return end - start
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func setTabBar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], for: UIControlState())
        let tabBarController = window?.rootViewController as! UITabBarController
        
        tabBarController.tabBar.tintColor = AppValues.textColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 49))
        
        tabBarController.tabBar.barTintColor = AppValues.primaryColor
        view.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.05)
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tabBarController.tabBar.selectionIndicatorImage = image
        
        let iconeHorloge = FAKIonIcons.iosClockIcon(withSize: 20)!
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![0].image = iconeHorloge.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![0].selectedImage = iconeHorloge.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconeAttention = FAKFontAwesome.warningIcon(withSize: 20)!
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![1].image = iconeAttention.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![1].selectedImage = iconeAttention.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconeItineraire = FAKFontAwesome.mapSignsIcon(withSize: 20)!
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![2].image = iconeItineraire.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![2].selectedImage = iconeItineraire.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconePlan = FAKFontAwesome.mapIcon(withSize: 20)!
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![3].image = iconePlan.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![3].selectedImage = iconePlan.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconeParametre = FAKFontAwesome.cogIcon(withSize: 20)!
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![4].image = iconeParametre.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![4].selectedImage = iconeParametre.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        if !defaults.bool(forKey: "tutorial") && !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            tabBarController.selectedIndex = 4
        }
        else if !defaults.bool(forKey: "version4") && !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            tabBarController.selectedIndex = 4
        }
        else {
            tabBarController.selectedIndex = defaults.integer(forKey: "selectedTabBar")
        }
    }
    
    func getDefaults() {
        
        let group = AsyncGroup()
        
        group.background {
            let dataArrets = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "arrets", ofType: "json")!))
            let arrets = JSON(data: dataArrets!)
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
                    connections: subJson["connections"].arrayObject as! [String]
                )
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
        }
        
        
        group.background {
            if self.defaults.object(forKey: "favoritesStops") == nil {
                AppValues.favoritesStops = [:]
            }
            else {
                let decoded  = self.defaults.object(forKey: "favoritesStops")
                let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as? [String:Stop]
                AppValues.favoritesStops = unarchivedData
                for (_, y) in AppValues.favoritesStops {
                    AppValues.fullNameFavoritesStops.append(y.fullName)
                }
                AppValues.fullNameFavoritesStops.sort(by: { (value1, value2) -> Bool in
                    if (value1.lowercased() < value2.lowercased()) {
                        return true
                    } else {
                        return false
                    }
                })
            }
        }
        
        
        group.background {
            let dataCouleurs = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "couleursLignes", ofType: "json")!))
            let couleurs = JSON(data: dataCouleurs!)
            for (_, j) in couleurs["colors"] {
                AppValues.linesBackgroundColor[j["lineCode"].string!] = UIColor(hexString: j["background"].string, withAlpha: 1)
                AppValues.linesColor[j["lineCode"].string!] = UIColor(hexString: j["text"].string, withAlpha: 1)
            }
        }
        
        
        group.background {
            var decoded = self.defaults.object(forKey: "itinerairesFavoris")
            if decoded == nil {
                decoded = []
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                self.defaults.set(encodedData, forKey: "itinerairesFavoris")
            }
            else {
                let tempUnarchivedData = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as? [[Any]]
                if tempUnarchivedData != nil {
                    if !tempUnarchivedData!.isEmpty {
                        let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as? [[Stop]]
                        AppValues.favoritesRoutes = unarchivedData
                    }
                    else {
                        AppValues.favoritesRoutes = []
                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                        self.defaults.set(encodedData, forKey: "itinerairesFavoris")
                    }
                }
                else {
                    AppValues.favoritesRoutes = []
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                    self.defaults.set(encodedData, forKey: "itinerairesFavoris")
                }
            }
            
            
            if self.defaults.colorForKey("primaryColor") == nil {
                self.defaults.setColor(AppValues.primaryColor, forKey: "primaryColor")
            }
            else {
                AppValues.primaryColor = self.defaults.colorForKey("primaryColor")
            }
            
            if self.defaults.colorForKey("textColor") == nil {
                self.defaults.setColor(AppValues.textColor, forKey: "textColor")
            }
            else {
                AppValues.textColor = self.defaults.colorForKey("textColor")
            }
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                UIApplication.shared.statusBarStyle = .lightContent
            }
            else {
                UIApplication.shared.statusBarStyle = .default
            }
        }
        
        group.wait()
    }
}
