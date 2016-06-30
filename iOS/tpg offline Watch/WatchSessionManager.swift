//
//  WatchSessionDelegate.swift
//  tpg offline
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchConnectivity
import Foundation

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    
    private override init() {
        super.init()
    }
    
    private let session: WCSession = WCSession.defaultSession()
    
    func startSession() {
        session.delegate = self
        session.activateSession()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if applicationContext["favoritesStops"] != nil {
            var favoritesStops = [String:Stop]()
            
            let tempUnarchive = NSKeyedUnarchiver.unarchiveObjectWithData(applicationContext["favoritesStops"] as! NSData) as! [String:[String:AnyObject]]
            for (x, y) in tempUnarchive {
                favoritesStops[x] = Stop(dictionnary: y)
            }
            
            AppValues.favoritesStops = favoritesStops
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(favoritesStops)
            defaults.setObject(encodedData, forKey: "favoritesStops")
        }
        
        if applicationContext["offlineDepartures"] != nil {
            let offlineDepartures = applicationContext["offlineDepartures"] as! [String: String]
            
            AppValues.offlineDepartures = offlineDepartures
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(offlineDepartures)
            defaults.setObject(encodedData, forKey: "offlineDepartures")
        }
    }
}