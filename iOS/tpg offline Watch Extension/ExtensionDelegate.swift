//
//  ExtensionDelegate.swift
//  tpg offline Watch Extension
//
//  Created by Rémy DA COSTA FARO on 20/08/2016.
//  Copyright © 2016 Rémy DA COSTA FARO. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        let defaults = UserDefaults.standard
        
        var decoded = defaults.object(forKey: "favoritesStops")
        if decoded != nil {
            let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as? [String:Stop]
            AppValues.favoritesStops = unarchivedData
        }
        
        decoded = defaults.object(forKey: "offlineDepartures")
        if decoded != nil {
            let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as? [String:String]
            AppValues.offlineDepartures = unarchivedData!
        }

        let dataCouleurs = NSData(contentsOfFile: Bundle.main.path(forResource: "colorLines", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs! as Data)
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

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }

}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
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
