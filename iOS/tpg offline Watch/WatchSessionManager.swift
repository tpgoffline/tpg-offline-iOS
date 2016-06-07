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
            AppValues.favoritesStops = NSKeyedUnarchiver.unarchiveObjectWithData(applicationContext["favoritesStops"] as! NSData) as! [String:Stop]
            print("a")
        }
    }
}