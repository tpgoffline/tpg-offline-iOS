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

enum TouchActions: String {
    case departures = "departures"
    case disruptions = "disruptions"
    case routes = "routes"
    case maps = "maps"

    var number: Int {
        switch self {
        case .maps:
            return 3
        case .routes:
            return 2
        case .disruptions:
            return 1
        case .departures:
            return 0
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
            print("WARNING: Debug mode, Crashlytics desactivated")
        #else
            Fabric.with([Crashlytics.self])
        #endif

        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/replacementsNames.json").responseJSON { (response) in
            if let json = response.result.value as? [String: String] {
                App.replacementsNames = json
            }
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, _) in
                if !accepted {
                    print("Notification access denied.")
                }
            }
        } else {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
        }

        if CommandLine.arguments.contains("-reset") {
            App.loadStops()
            App.favoritesStops = [App.stops.filter({ $0.code == "CVIN"})[0].appId]
            App.favoritesRoutes = [Route(from: App.stops.filter({ $0.code == "31DC"})[0],
                                         to: App.stops.filter({ $0.code == "CVIN"})[0],
                                         date: Date(), arrivalTime: false)]
            window?.layer.cornerRadius = 0
            window?.clipsToBounds = true
            return true
        }

        if let tabController = (window?.rootViewController as? UITabBarController) {
            tabController.selectedIndex = App.defaultTab
        }

        App.loadLines()
        return App.loadStops()
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

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let type = TouchActions(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }

        let selectedIndex = type.number
        (window?.rootViewController as? UITabBarController)?.selectedIndex = selectedIndex

        completionHandler(true)
    }
}
