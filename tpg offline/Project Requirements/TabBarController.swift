//
//  TabBarController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 01/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.tabBar.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        self.tabBar.barStyle = App.darkMode ? .black : .default
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch self.selectedIndex {
        case 0:
            App.log("TabBar: Switch to Departures")
        case 1:
            App.log("TabBar: Switch to Disruptions")
        case 2:
            App.log("TabBar: Switch to Routes")
        case 3:
            App.log("TabBar: Switch to Maps")
        case 4:
            App.log("TabBar: Switch to Settings")
        default:
            App.log("TabBar: Switch to an unknow item")
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
