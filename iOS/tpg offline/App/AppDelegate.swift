//
//  AppDelegate.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import CoreLocation
import Chameleon
import Fabric
import Crashlytics
import FontAwesomeKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
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
}
