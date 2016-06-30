//
//  ExtensionDelegate.swift
//  tpg offline Watch Extension
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchKit
import SwiftyJSON

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var decoded = defaults.objectForKey("arretsFavoris")
        if decoded != nil {
            let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [String:Stop]
            AppValues.favoritesStops = unarchivedData
        }
        
        decoded = defaults.objectForKey("offlineDepartures")
        if decoded != nil {
            let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as? [String:String]
            AppValues.offlineDepartures = unarchivedData!
        }

        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for (_, j) in couleurs["colors"] {
            AppValues.linesBackgroundColor[j["lineCode"].string!] = UIColor(hexString: j["background"].string!)
            AppValues.linesColor[j["lineCode"].string!] = UIColor(hexString: j["text"].string!)
        }
        
        WatchSessionManager.sharedManager.startSession()
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
