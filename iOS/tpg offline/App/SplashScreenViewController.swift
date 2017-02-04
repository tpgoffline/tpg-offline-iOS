//
//  SplashScreenViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 24/10/2016.
//  Copyright © 2016 Rémy DA COSTA FARO. All rights reserved.
//

import UIKit
import FontAwesomeKit
import CoreLocation
import Chameleon
import Alamofire
import FirebaseAnalytics

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
        
        Async.main {
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
            self.setUpTabBar(segue.destination as! UITabBarController)
        }
    }
    
    func setUpTabBar(_ tabBarController: UITabBarController!) {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], for: UIControlState())
        
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
        var iconImage = iconeHorloge.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![0].image = iconImage
        tabBarController.tabBar.items![0].selectedImage = iconImage
        
        let iconeAttention = FAKFontAwesome.warningIcon(withSize: 20)!
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconeAttention.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![1].image = iconImage
        tabBarController.tabBar.items![1].selectedImage = iconImage
        
        let iconeItineraire = FAKFontAwesome.mapSignsIcon(withSize: 20)!
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconeItineraire.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![2].image = iconImage
        tabBarController.tabBar.items![2].selectedImage = iconImage
        
        let iconePlan = FAKFontAwesome.mapIcon(withSize: 20)!
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconePlan.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![3].image = iconImage
        tabBarController.tabBar.items![3].selectedImage = iconImage
        
        let iconeParametre = FAKFontAwesome.cogIcon(withSize: 20)!
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconeParametre.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController.tabBar.items![4].image = iconImage
        tabBarController.tabBar.items![4].selectedImage = iconImage
        
        if !self.defaults.bool(forKey: "tutorial") && !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            tabBarController.selectedIndex = 4
        }
        else {
            tabBarController.selectedIndex = self.defaults.integer(forKey: "selectedTabBar")
        }
        
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/Departs/infos.json", method: .get).responseData { (request) in
            if request.result.isSuccess {
                let json = JSON(data: request.data!)
                if json["version"].intValue != self.defaults.integer(forKey: UserDefaultsKeys.offlineDeparturesVersion.rawValue) {
                    AppValues.needUpdateDepartures = true
                    tabBarController.selectedIndex = 4
                }
            }
        }
    }
    
    func getDefaults() {
        let group = AsyncGroup()
        
        group.background {
            let data: Data!
            if let data2 = self.defaults.data(forKey: UserDefaultsKeys.stops.rawValue) {
                data = data2
            }
            else {
                data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "stops", ofType: "json")!))
            }
            let arrets = JSON(data: data)
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
            let dataCouleurs = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "colorLines", ofType: "json")!))
            let couleurs = JSON(data: dataCouleurs!)
            for (_, j) in couleurs["colors"] {
                AppValues.linesBackgroundColor[j["lineCode"].string!] = UIColor(hexString: j["background"].string!, withAlpha: 1)
                AppValues.linesColor[j["lineCode"].string!] = UIColor(hexString: j["text"].string!, withAlpha: 1)
            }
        }
        
        
        group.background {
            var decoded = self.defaults.object(forKey: UserDefaultsKeys.favoritesRoutes.rawValue)
            if decoded == nil {
                decoded = []
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                self.defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesRoutes.rawValue)
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
                        self.defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesRoutes.rawValue)
                    }
                }
                else {
                    AppValues.favoritesRoutes = []
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: [])
                    self.defaults.set(encodedData, forKey: UserDefaultsKeys.textColor.rawValue)
                }
            }
            
            
            if self.defaults.colorForKey(UserDefaultsKeys.primaryColor.rawValue) == nil {
                self.defaults.setColor(AppValues.primaryColor, forKey: UserDefaultsKeys.primaryColor.rawValue)
            }
            else {
                AppValues.primaryColor = self.defaults.colorForKey(UserDefaultsKeys.primaryColor.rawValue)
            }
            
            if self.defaults.colorForKey(UserDefaultsKeys.textColor.rawValue) == nil {
                self.defaults.setColor(AppValues.textColor, forKey: UserDefaultsKeys.textColor.rawValue)
            }
            else {
                AppValues.textColor = self.defaults.colorForKey(UserDefaultsKeys.textColor.rawValue)
            }
            
            #if DEBUG
                print("\(AppValues.primaryColor.hexValue()) \(AppValues.textColor.hexValue())")
            #else
                FIRAnalytics.setUserPropertyString("\(AppValues.primaryColor.hexValue()) \(AppValues.textColor.hexValue())", forName: "theme")
            #endif
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                UIApplication.shared.statusBarStyle = .lightContent
            }
            else {
                UIApplication.shared.statusBarStyle = .default
            }
        }
        
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/tpg%20offline/Project%20Requirements/stops.json", method: .get).responseData { (request) in
            if request.result.isSuccess {
                self.defaults.set(request.data!, forKey: UserDefaultsKeys.stops.rawValue)
            }
        }
        
        
        
        group.wait()
    }
}
