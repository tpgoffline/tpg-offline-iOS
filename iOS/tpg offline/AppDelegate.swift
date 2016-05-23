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
        
        if !defaults.boolForKey("tutorial") {
            tabBarController.selectedIndex = 4
        }
        else {
            tabBarController.selectedIndex = defaults.integerForKey("selectedTabBar")
        }
    }
    
    func getDefaults() {
        let group = AsyncGroup()
        group.background {
            AppValues.logger.debug("Initialisation du chargement des arrets")
            
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
            
            AppValues.arretsKeys = [String](AppValues.arrets.keys)
            AppValues.arretsKeys.sortInPlace({ (string1, string2) -> Bool in
                let stringA = String((AppValues.arrets[string1]?.titre)! + (AppValues.arrets[string1]?.sousTitre)!)
                let stringB = String((AppValues.arrets[string2]?.titre)! + (AppValues.arrets[string2]?.sousTitre)!)
                if stringA.lowercaseString < stringB.lowercaseString {
                    return true
                }
                return false
            })
            AppValues.logger.info("Chargement des arrets terminé")
            
        }
        group.background {
            AppValues.logger.debug("Initialisation du chargement des arrets favoris")
            if self.defaults.objectForKey("arretsFavoris") == nil {
                AppValues.arretsFavoris = [:]
            }
            else {
                let decoded  = self.defaults.objectForKey("arretsFavoris")
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
            AppValues.logger.info("Chargement des arrets favoris terminé")
        }
        
        group.background {
            let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
            let couleurs = JSON(data: dataCouleurs!)
            for i in 0 ..< couleurs["colors"].count {
                AppValues.listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string, withAlpha: 1)
                AppValues.listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string, withAlpha: 1)
            }
            AppValues.logger.info("Chargement des couleurs terminées")
        }
        
        group.background {
            AppValues.logger.debug("Initialisation du NSUserDefaults")
            var decoded = self.defaults.objectForKey("itinerairesFavoris")
            if decoded == nil {
                decoded = []
                let encodedData = NSKeyedArchiver.archivedDataWithRootObject([])
                self.defaults.setObject(encodedData, forKey: "itinerairesFavoris")
            }
            else {
                AppValues.favorisItineraires = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [[Arret]]
                if AppValues.favorisItineraires == nil {
                    AppValues.favorisItineraires = []
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
            AppValues.logger.info("NSUserDefaults terminé")
        }
        
        group.wait()
        AppValues.logger.info("Async terminé")
    }
}
