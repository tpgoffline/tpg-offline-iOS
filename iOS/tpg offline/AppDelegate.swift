//
//  AppDelegate.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit
import CoreLocation
import ChameleonFramework
import Async
import Fabric
import Crashlytics
import SwiftTweaks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        /*let rootVc = window?.rootViewController
         window = TweakWindow(frame: UIScreen.mainScreen().bounds, tweakStore: TpgOfflineTweaks.defaultStore)
         window!.rootViewController = rootVc
         window!.makeKeyAndVisible()*/
        
        AppValues.logger.enabled = true
        //Fabric.with([Crashlytics.self])
        if #available(iOS 9.0, *) {
            WatchSessionManager.sharedManager.startSession()
        }
        
        getDefaults()
        setTabBar()
        
        return true
    }
    
    func executionTimeInterval(block: () -> ()) -> CFTimeInterval {
        let start = CACurrentMediaTime()
        block();
        let end = CACurrentMediaTime()
        return end - start
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    func setTabBar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], forState: .Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], forState: .Normal)
        let tabBarController = window?.rootViewController as! UITabBarController
        
        tabBarController.tabBar.tintColor = AppValues.textColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 49))
        
        if ContrastColorOf(AppValues.secondaryColor, returnFlat: true) == FlatWhite() {
            tabBarController.tabBar.barTintColor = AppValues.secondaryColor
            view.backgroundColor = AppValues.secondaryColor.darkenByPercentage(0.1)
        }
        else {
            tabBarController.tabBar.barTintColor = AppValues.secondaryColor.darkenByPercentage(0.1)
            view.backgroundColor = AppValues.secondaryColor
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tabBarController.tabBar.selectionIndicatorImage = image
        
        let iconeHorloge = FAKIonIcons.iosClockIconWithSize(20)
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![0].image = iconeHorloge.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController.tabBar.items![0].selectedImage = iconeHorloge.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeAttention = FAKFontAwesome.warningIconWithSize(20)
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![1].image = iconeAttention.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController.tabBar.items![1].selectedImage = iconeAttention.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeItineraire = FAKFontAwesome.mapSignsIconWithSize(20)
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![2].image = iconeItineraire.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController.tabBar.items![2].selectedImage = iconeItineraire.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconePlan = FAKFontAwesome.mapIconWithSize(20)
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![3].image = iconePlan.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController.tabBar.items![3].selectedImage = iconePlan.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeParametre = FAKFontAwesome.cogIconWithSize(20)
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController.tabBar.items![4].image = iconeParametre.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController.tabBar.items![4].selectedImage = iconeParametre.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        if !defaults.boolForKey("tutorial") && !(NSProcessInfo.processInfo().arguments.contains("-donotask")){
            tabBarController.selectedIndex = 4
        }
        else {
            tabBarController.selectedIndex = defaults.integerForKey("selectedTabBar")
        }
    }
    
    func getDefaults() {
        let group = AsyncGroup()
        group.background {
            let dataArrets = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("arrets", ofType: "json")!)
            let arrets = JSON(data: dataArrets!)
            for (_, subJson) in arrets["stops"] {
                AppValues.stopCodeToStopItem[subJson["stopCode"].string!] = subJson["stopName"].string!
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
            AppValues.stopsKeys.sortInPlace({ (string1, string2) -> Bool in
                let stringA = String((AppValues.stops[string1]?.title)! + (AppValues.stops[string1]?.subTitle)!)
                let stringB = String((AppValues.stops[string2]?.title)! + (AppValues.stops[string2]?.subTitle)!)
                if stringA.lowercaseString < stringB.lowercaseString {
                    return true
                }
                return false
            })
        }
        group.background {
            if self.defaults.objectForKey("arretsFavoris") == nil {
                AppValues.favoritesStops = [:]
            }
            else {
                let decoded  = self.defaults.objectForKey("arretsFavoris")
                let tempUnarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [String:AnyObject]
                if ((tempUnarchivedData?[Array(tempUnarchivedData!.keys)[0]]!.isKindOfClass(Arret)) == true) {
                    var favoritesStops:[String:Stop] = [:]
                    for (key, x) in tempUnarchivedData! {
                        favoritesStops[key] = Stop(stop: x as! Arret)
                    }
                    let encodedData = NSKeyedArchiver.archivedDataWithRootObject(favoritesStops)
                    self.defaults.setObject(encodedData, forKey: "arretsFavoris")
                    AppValues.favoritesStops = favoritesStops
                }
                else if ((tempUnarchivedData?[Array(tempUnarchivedData!.keys)[0]]!.isKindOfClass(Stop)) == true) {
                    let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [String:Stop]
                    AppValues.favoritesStops = unarchivedData
                }
                for (_, y) in AppValues.favoritesStops {
                    AppValues.fullNameFavoritesStops.append(y.fullName)
                }
                AppValues.fullNameFavoritesStops = AppValues.fullNameFavoritesStops.sort({ (value1, value2) -> Bool in
                    if (value1.lowercaseString < value2.lowercaseString) {
                        return true
                    } else {
                        return false
                    }
                })
            }
        }
        
        group.background {
            let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
            let couleurs = JSON(data: dataCouleurs!)
            for i in 0 ..< couleurs["colors"].count {
                AppValues.linesBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string, withAlpha: 1)
                AppValues.linesColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string, withAlpha: 1)
            }
        }
        
        group.background {
            var decoded = self.defaults.objectForKey("itinerairesFavoris")
            if decoded == nil {
                decoded = []
                let encodedData = NSKeyedArchiver.archivedDataWithRootObject([])
                self.defaults.setObject(encodedData, forKey: "itinerairesFavoris")
            }
            else {
                let tempUnarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [[AnyObject]]
                if tempUnarchivedData != nil {
                    if !tempUnarchivedData!.isEmpty {
                        if ((tempUnarchivedData?[0][0].isKindOfClass(Arret)) == true) {
                            var favoriteRoutes:[[Stop]] = []
                            for x in tempUnarchivedData! {
                                var subArray: [Stop] = []
                                for y in x {
                                    subArray.append(Stop(stop: (y as! Arret)))
                                }
                                favoriteRoutes.append(subArray)
                            }
                            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(favoriteRoutes)
                            self.defaults.setObject(encodedData, forKey: "itinerairesFavoris")
                            AppValues.favoritesRoutes = favoriteRoutes
                        }
                        else if ((tempUnarchivedData?[0][0].isKindOfClass(Stop)) == true) {
                            let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [[Stop]]
                            AppValues.favoritesRoutes = unarchivedData
                        }
                    }
                    else {
                        AppValues.favoritesRoutes = []
                        let encodedData = NSKeyedArchiver.archivedDataWithRootObject([])
                        self.defaults.setObject(encodedData, forKey: "itinerairesFavoris")
                    }
                }
                else {
                    AppValues.favoritesRoutes = []
                    let encodedData = NSKeyedArchiver.archivedDataWithRootObject([])
                    self.defaults.setObject(encodedData, forKey: "itinerairesFavoris")
                }
            }
            
            if (NSProcessInfo.processInfo().arguments.contains("-premium")) {
                AppValues.premium = true
            }
            else {
                AppValues.premium = self.defaults.boolForKey("premium")
            }
            
            
            if self.defaults.colorForKey("primaryColor") == nil {
                self.defaults.setColor(AppValues.primaryColor, forKey: "primaryColor")
            }
            else {
                AppValues.primaryColor = self.defaults.colorForKey("primaryColor")
            }
            
            if self.defaults.colorForKey("secondaryColor") == nil {
                self.defaults.setColor(AppValues.secondaryColor, forKey: "secondaryColor")
            }
            else {
                AppValues.secondaryColor = self.defaults.colorForKey("secondaryColor")
            }
            
            if self.defaults.colorForKey("textColor") == nil {
                self.defaults.setColor(AppValues.textColor, forKey: "textColor")
            }
            else {
                AppValues.textColor = self.defaults.colorForKey("textColor")
            }
        }
        
        group.wait()
    }
}
