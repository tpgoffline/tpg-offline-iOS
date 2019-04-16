//
//  AppDelegate.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 09/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import CoreSpotlight
import Firebase
import Crashlytics
import Intents

enum TouchActions: String {
  case departures = "departures"
  case disruptions = "disruptions"
  case routes = "routes"
  case orientation = "orientation"

  var number: Int {
    switch self {
    case .orientation:
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
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //swiftlint:disable:previous line_length
    #if DEBUG
    print("WARNING: Debug mode, Crashlytics deactivated")
   FirebaseApp.configure()
    #else
    if App.fabric {
      FirebaseApp.configure()
    }
    #endif

    App.darkMode = UserDefaults.standard.bool(forKey: "darkMode")
    if App.automaticDarkMode,
      App.sunriseSunsetManager?.isDaytime ?? false,
      App.darkMode == true {
      App.darkMode = false
    } else if App.automaticDarkMode,
      App.sunriseSunsetManager?.isNighttime ?? false,
      App.darkMode == false {
      App.darkMode = true
    }

    Alamofire.request(URL.replacementNames).responseJSON { (response) in
      if let json = response.result.value as? [String: String] {
        App.replacementsNames = json
      }
    }

    window?.layer.cornerRadius = 5
    window?.clipsToBounds = true

    if #available(iOS 10.0, *) {
      INPreferences.requestSiriAuthorization { status in
        if status == .authorized {
          print("Hey, Siri!")
        } else {
          print("Nay, Siri!")
        }
      }
    }

    if let tabController = (window?.rootViewController as? UITabBarController) {
      tabController.selectedIndex = App.defaultTab

      if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        as? String, version != UserDefaults.standard.string(forKey: "lastVersion"),
        UserDefaults.standard.string(forKey: "lastVersion") != nil {
        tabController.selectedIndex = 4
      }

      if CommandLine.arguments.contains("-reset") {
        tabController.selectedIndex = 0
      }

      tabController.tabBar.items![0].image = #imageLiteral(resourceName: "clockTabBar")
      tabController.tabBar.items![0].selectedImage = #imageLiteral(resourceName: "clockTabBar")
      tabController.tabBar.items![0].title = "Departures".localized
      tabController.tabBar.items![1].image = #imageLiteral(resourceName: "warningTabBar")
      tabController.tabBar.items![1].selectedImage = #imageLiteral(resourceName: "warningTabBar")
      tabController.tabBar.items![1].title = "Disruptions".localized
      tabController.tabBar.items![2].image = #imageLiteral(resourceName: "routesTabBar")
      tabController.tabBar.items![2].selectedImage = #imageLiteral(resourceName: "routesTabBar")
      tabController.tabBar.items![2].title = "Routes".localized
      tabController.tabBar.items![3].image = #imageLiteral(resourceName: "orientationTabBar")
      tabController.tabBar.items![3].selectedImage = #imageLiteral(resourceName: "orientationTabBar")
      tabController.tabBar.items![3].title = "Orientation".localized
      tabController.tabBar.items![4].image = #imageLiteral(resourceName: "settingsTabBar")
      tabController.tabBar.items![4].selectedImage = #imageLiteral(resourceName: "settingsTabBar")
      tabController.tabBar.items![4].title = "Settings".localized
    }

    if CommandLine.arguments.contains("-reset") {
      App.loadStops()
      App.loadLines()
      App.darkMode = false
      App.favoritesStops = [App.stops.filter({ $0.code == "CVIN"})[0].appId]
      App.favoritesRoutes = [Route(from: App.stops.filter({ $0.code == "31DC"})[0],
                                   to: App.stops.filter({ $0.code == "CVIN"})[0],
                                   via: [],
                                   date: Date(), arrivalTime: false)]
      App.automaticDarkMode = false
      return true
    }

    UIApplication.shared.statusBarStyle = App.darkMode ? .lightContent : .default
    App.loadLines()
    return App.loadStops()
  }

  func application(_ application: UIApplication,
                   continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    // swiftlint:disable:previous line_length
    if userActivity.activityType == CSSearchableItemActionType,
      let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
      let tabController = (window?.rootViewController as? UITabBarController) {
      tabController.selectedIndex = 0
      if let splitViewController = tabController.viewControllers?.first
        as? UISplitViewController,
        let navigationController = splitViewController.viewControllers.first
          as? UINavigationController {
        navigationController.popToRootViewController(animated: false)
        if let viewController = navigationController.topViewController
          as? StopsTableViewController {
          guard let stop = App.stops.filter({ $0.appId == Int(id) })[safe: 0] else {
            return false
          }
          viewController.presentStopFromAppDelegate(stop: stop)
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
                   performActionFor shortcutItem: UIApplicationShortcutItem,
                   completionHandler: @escaping (Bool) -> Void) {
    guard let type = TouchActions(rawValue: shortcutItem.type) else {
      completionHandler(false)
      return
    }

    let currentIndex = type.number
    (window?.rootViewController as? UITabBarController)?.selectedIndex = currentIndex

    completionHandler(true)
  }

  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //swiftlint:disable:previous line_length
    completionHandler([.alert, .badge, .sound])
  }
}
