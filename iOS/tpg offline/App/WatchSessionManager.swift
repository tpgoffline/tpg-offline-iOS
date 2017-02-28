//
//  WatchSessionManager.swift
//  tpg offline
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    open func sessionDidDeactivate(_ session: WCSession) {

    }

    open func sessionDidBecomeInactive(_ session: WCSession) {

    }

    open func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    static let sharedManager = WatchSessionManager()
    fileprivate override init() {
        super.init()
    }

    fileprivate let watchSession: WCSession? = WCSession.isSupported() ? WCSession.default() : nil

    fileprivate var validSession: WCSession? {
        if let session = watchSession, session.isPaired && session.isWatchAppInstalled {
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
