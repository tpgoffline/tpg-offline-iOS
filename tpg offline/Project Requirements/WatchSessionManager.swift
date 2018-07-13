//
//  WatchSessionManager.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 11/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    open func sessionDidDeactivate(_ session: WCSession) {

    }

    open func sessionDidBecomeInactive(_ session: WCSession) {

    }

    @available(iOS 9.3, *)
    open func session(_ session: WCSession,
                      activationDidCompleteWith activationState: WCSessionActivationState, // swiftlint:disable:this line_length
                      error: Error?) {

    }

    static let shared = WatchSessionManager()

    fileprivate override init() {
        super.init()
        self.startSession()
    }

    fileprivate let watchSession: WCSession? = WCSession.isSupported() ?
      WCSession.default : nil

    fileprivate var validSession: WCSession? {
        if let session = watchSession,
          session.isPaired,
          session.isWatchAppInstalled {
            return session
        }
        return nil
    }

    func startSession() {
        watchSession?.delegate = self
        watchSession?.activate()
    }

    func updateApplicationContext(_ applicationContext: [String: Any]) throws {
        do {
            try watchSession!.updateApplicationContext(applicationContext)
        } catch let error {
            print("Error : \(error)")
            throw error
        }
    }

    func sync() {
        if WCSession.isSupported() {
            do {
                let encoder = JSONEncoder()
                let favoritesRoutes = try App.favoritesRoutes
                    .map({ try encoder.encode($0) })
                let applicationDict: [String: Any] = [
                    "favoritesStops": App.favoritesStops,
                    "favoritesRoutes": favoritesRoutes,
                    "replacementsNames": App.replacementsNames,
                    "smartReminders": App.smartReminders,
                    "apnsToken": App.apnsToken
                ]
                try self.updateApplicationContext(applicationDict)
            } catch {
                print("Sync error")
            }
        }
    }
}
