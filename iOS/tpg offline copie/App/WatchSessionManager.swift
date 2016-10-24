//
//  WatchSessionManager.swift
//  tpg offline
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    open func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    open func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    open func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    
    static let sharedManager = WatchSessionManager()
    fileprivate override init() {
        super.init()
    }
    
    fileprivate let watchSession: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    fileprivate var validSession: WCSession? {
        if let session = watchSession , session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    func startSession() {
        watchSession?.delegate = self
        watchSession?.activate()
    }
    
    func updateApplicationContext(_ applicationContext: [String : Any]) throws {
        do {
            try watchSession!.updateApplicationContext(applicationContext)
        } catch let error {
            print("Error : \(error)")
            throw error
        }
    }
}
