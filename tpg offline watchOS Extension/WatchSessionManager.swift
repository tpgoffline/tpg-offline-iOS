//
//  WatchSessionManager.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 11/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchConnectivity
import Foundation

class WatchSessionManager: NSObject, WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    static let sharedManager = WatchSessionManager()

    fileprivate override init() {
        super.init()
    }

    fileprivate let session: WCSession = WCSession.default

    func startSession() {
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let favoritesStops = applicationContext["favoritesStops"] as? [Int] {
            App.favoritesStops = favoritesStops
        }
        if let replacementsNames = applicationContext["replacementsNames"] as? [String: String] {
            App.replacementsNames = replacementsNames
        }
        if let favoritesRoutesA = applicationContext["favoritesRoutes"] as? [Data] {
            do {
            let decoder = JSONDecoder()
            let favoritesRoutes = try favoritesRoutesA.map({ try decoder.decode(Route.self, from: $0) })
            App.favoritesRoutes = favoritesRoutes
            } catch {
                print("Can't decode favoritesRoutes")
            }
        }
        DispatchQueue.main.async {
            self.appDataChangedDelegates.forEach { $0.appDataDidUpdate() }
        }
    }

    private var appDataChangedDelegates = [AppDataChangedDelegate]()

    func addAppDataChangedDelegate<T>(delegate: T) where T: AppDataChangedDelegate, T: Equatable {
        appDataChangedDelegates.append(delegate)
    }

    func removeAppDataChangedDelegate<T>(delegate: T) where T: AppDataChangedDelegate, T: Equatable {
        for (index, appDataDelegate) in appDataChangedDelegates.enumerated() {
            if let appDataDelegate = appDataDelegate as? T, appDataDelegate == delegate {
                appDataChangedDelegates.remove(at: index)
                break
            }
        }
    }
}

protocol AppDataChangedDelegate: class {
    func appDataDidUpdate()
}
