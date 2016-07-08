//
//  UIKitExtension.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import ChameleonFramework

extension UIViewController {
    func refreshTheme() {
        navigationController?.navigationBar.barTintColor = AppValues.primaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor
        
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        }
        else {
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
        if self.splitViewController != nil {
            if ((self.splitViewController?.viewControllers[0].isKindOfClass(UINavigationController)) == true) {
                (self.splitViewController?.viewControllers[0] as! UINavigationController).navigationBar.barTintColor = AppValues.primaryColor
                (self.splitViewController?.viewControllers[0] as! UINavigationController).navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
                (self.splitViewController?.viewControllers[0] as! UINavigationController).navigationBar.tintColor = AppValues.textColor
            }
            if self.splitViewController?.viewControllers.count != 1 {
                if ((self.splitViewController?.viewControllers[1].isKindOfClass(UINavigationController)) == true) {
                    (self.splitViewController?.viewControllers[1] as! UINavigationController).navigationBar.barTintColor = AppValues.primaryColor
                    (self.splitViewController?.viewControllers[1] as! UINavigationController).navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
                    (self.splitViewController?.viewControllers[1] as! UINavigationController).navigationBar.tintColor = AppValues.textColor
                }
            }
        }
    }
}

extension UITableViewController {
    override func refreshTheme() {
        super.refreshTheme()
        
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
    }
}