//
//  AppDelegate.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 09/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import CoreSpotlight
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])

        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/v13/JSON/replacementsNames.json").responseJSON { (response) in
            if let json = response.result.value as? [String: String] {
                App.replacementsNames = json
            }
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "stops", ofType: "json")!))
            let decoder = JSONDecoder()
            let stops = try decoder.decode([Stop].self, from: data)
            App.stops = stops.sorted(by: { (stop1, stop2) -> Bool in
                if stop1.name < stop2.name {
                    return true
                }
                return false
            })
            for stop in App.stops.map({ $0.name }) {
                let character = "\(stop.first!)"
                App.sortedStops[character, default: []].append(stop)
            }
            for (i, id) in App.favoritesStops.enumerated() {
                if App.stops.filter({ $0.appId == id })[safe: 0] == nil {
                    App.favoritesStops.remove(at: i)
                }
            }

        } catch {
            print("error")
            return true
        }

        window?.layer.cornerRadius = 5
        window?.clipsToBounds = true

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, _) in
                if !accepted {
                    print("Notification access denied.")
                }
            }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let tabController = (window?.rootViewController as? UITabBarController) {
                    tabController.selectedIndex = 0
                    if let navigationController = tabController.viewControllers?[0] as? UINavigationController {
                        navigationController.popToRootViewController(animated: false)
                        if let viewController = navigationController.topViewController as? StopsTableViewController {
                            guard let stop = App.stops.filter({ $0.appId == Int(id) })[safe: 0] else {
                                return false
                            }
                            viewController.presentStopFromAppDelegate(stop: stop)
                        }
                    }
                }
            }
        }

        return true
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
