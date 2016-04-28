//
//  AppDelegate.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit
import CoreLocation
import ChameleonFramework
//import SimulatorStatusMagic

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        AppValues.logger.enabled = true
        
        if (NSProcessInfo.processInfo().arguments.contains("-takeScreenshot")) {
            //SDStatusBarManager.sharedInstance().enableOverrides()
        }
        
        if defaults.objectForKey("arretsFavoris") == nil {
            AppValues.arretsFavoris = [:]
        }
        else {
            let decoded  = defaults.objectForKey("arretsFavoris")
            AppValues.arretsFavoris = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as! [String:Arret]
            for (_, y) in AppValues.arretsFavoris {
                AppValues.nomCompletsFavoris.append(y.nomComplet)
            }
            AppValues.nomCompletsFavoris = AppValues.nomCompletsFavoris.sort({ (value1, value2) -> Bool in
                if (value1.lowercaseString < value2.lowercaseString) {
                    return true
                } else {
                    return false
                }
            })
        }
        
        var decoded = defaults.objectForKey("itinerairesFavoris")
        if decoded == nil {
            decoded = []
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject([])
            defaults.setObject(encodedData, forKey: "itinerairesFavoris")
        }
        else {
            AppValues.favorisItineraires = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [[Arret]]
            if AppValues.favorisItineraires == nil {
                AppValues.favorisItineraires = []
                let encodedData = NSKeyedArchiver.archivedDataWithRootObject([])
                defaults.setObject(encodedData, forKey: "itinerairesFavoris")
            }
        }
        
        if (NSProcessInfo.processInfo().arguments.contains("-premium")) {
            AppValues.premium = true
        }
        else {
            AppValues.premium = defaults.boolForKey("premium")
        }
        
        
        if defaults.colorForKey("primaryColor") == nil {
            defaults.setColor(AppValues.primaryColor, forKey: "primaryColor")
        }
        else {
            AppValues.primaryColor = defaults.colorForKey("primaryColor")
        }
        
        if defaults.colorForKey("secondaryColor") == nil {
            defaults.setColor(AppValues.secondaryColor, forKey: "secondaryColor")
        }
        else {
            AppValues.secondaryColor = defaults.colorForKey("secondaryColor")
        }
        
        if defaults.colorForKey("textColor") == nil {
            defaults.setColor(AppValues.textColor, forKey: "textColor")
        }
        else {
            AppValues.textColor = defaults.colorForKey("textColor")
        }
        
        // Tab Bar
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
        
        if !defaults.boolForKey("tutorial") {
            tabBarController.selectedIndex = 4
        }
        else {
            tabBarController.selectedIndex = defaults.integerForKey("selectedTabBar")
        }
        
        
        let dataArrets = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("arrets", ofType: "json")!)
        let arrets = JSON(data: dataArrets!)
        for (_, subJson) in arrets["stops"] {
            AppValues.stopCodeToArret[subJson["stopCode"].string!] = subJson["stopName"].string!
            AppValues.arrets[subJson["stopName"].string!] = Arret(
                nomComplet: subJson["stopName"].string!,
                titre: subJson["titleName"].string!,
                sousTitre: subJson["subTitleName"].string!,
                stopCode: subJson["stopCode"].string!,
                location: CLLocation(
                    latitude: subJson["locationX"].double!,
                    longitude: subJson["locationY"].double!
                ),
                idTransportAPI: subJson["idTransportAPI"].string!,
                connections: subJson["connections"].arrayObject as! [String]
            )
        }
        return true
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
    
    
}

