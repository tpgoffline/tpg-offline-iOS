//
//  AppDelegate.swift
//  tpg offline
//
//  Created by Alice on 22/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil))
        
        // Override point for customization after application launch.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let tpgUrl = tpgURL()
        
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

        // Tab Bar
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        let tabBarController = window?.rootViewController as! UITabBarController
        tabBarController.tabBar.barTintColor = UIColor.flatOrangeColorDark()
        tabBarController.tabBar.tintColor = UIColor.whiteColor()
        
        tabBarController.moreNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        tabBarController.moreNavigationController.navigationBar.barTintColor = UIColor.flatOrangeColorDark()
        tabBarController.moreNavigationController.navigationBar.tintColor = UIColor.whiteColor()
        
        let iconeHorloge = FAKIonIcons.iosClockIconWithSize(20)
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController.tabBar.items![0].image = iconeHorloge.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeAttention = FAKFontAwesome.warningIconWithSize(20)
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController.tabBar.items![1].image = iconeAttention.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeItineraire = FAKFontAwesome.mapSignsIconWithSize(20)
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController.tabBar.items![2].image = iconeItineraire.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconePlan = FAKFontAwesome.mapIconWithSize(20)
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController.tabBar.items![3].image = iconePlan.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
 
        let iconeParametre = FAKFontAwesome.cogIconWithSize(20)
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController.tabBar.items![4].image = iconeParametre.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        tabBarController.selectedIndex = defaults.integerForKey("selectedTabBar")
        
        
        if let dataArrets = tpgUrl.getAllStops() {
            let arrets = JSON(data: dataArrets)
            
            
            for (_, subJson) in arrets["stops"] {
                AppValues.arrets[subJson["stopName"].string!] = Arret(
                    nomComplet: subJson["stopName"].string!,
                    titre: subJson["titleName"].string!,
                    sousTitre: subJson["subTitleName"].string!,
                    stopCode: subJson["stopCode"].string!,
                    location: CLLocation(
                        latitude: subJson["locationX"].double!,
                        longitude: subJson["locationY"].double!
                    ),
                    idTransportAPI: subJson["idTransportAPI"].string!
                )
            }
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

