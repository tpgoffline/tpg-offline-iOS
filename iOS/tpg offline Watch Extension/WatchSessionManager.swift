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
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    
    static let sharedManager = WatchSessionManager()
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate let session: WCSession = WCSession.default()
    
    func startSession() {
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if applicationContext["favoritesStops"] != nil {
            var favoritesStops = [String:Stop]()
            
            let tempUnarchive = NSKeyedUnarchiver.unarchiveObject(with: applicationContext["favoritesStops"] as! Data) as! [String:[String:Any]]
            for (x, y) in tempUnarchive {
                favoritesStops[x] = Stop(dictionnary: y)
            }
            
            AppValues.favoritesStops = favoritesStops
            
            let defaults = UserDefaults.standard
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: favoritesStops)
            defaults.set(encodedData, forKey: "favoritesStops")
        }
        
        if applicationContext["offlineDepartures"] != nil {
            let offlineDepartures = applicationContext["offlineDepartures"] as! [String: String]
            
            AppValues.offlineDepartures = offlineDepartures
            
            let defaults = UserDefaults.standard
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: offlineDepartures)
            defaults.set(encodedData, forKey: "offlineDepartures")
        }
    }
}
