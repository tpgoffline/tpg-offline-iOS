//
//  WatchSessionManager.swift
//  tpg offline
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchConnectivity

@available(iOS 9.0, *)
class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    private let watchSession: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    private var validSession: WCSession? {
        if let session = watchSession where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
    
    func startSession() {
        watchSession?.delegate = self
        watchSession?.activateSession()
    }
    
    func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
        do {
            try watchSession!.updateApplicationContext(applicationContext)
        } catch let error {
            AppValues.logger.error("Error : \(error)")
            throw error
        }
    }
}