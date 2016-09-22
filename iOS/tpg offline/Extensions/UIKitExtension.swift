//
//  UIKitExtension.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Chameleon

extension UIViewController {
    func refreshTheme() {
        navigationController?.navigationBar.barTintColor = AppValues.primaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor
        
        if self.splitViewController != nil {
            if ((self.splitViewController?.viewControllers[0].isKind(of: UINavigationController.self)) == true) {
                (self.splitViewController?.viewControllers[0] as! UINavigationController).navigationBar.barTintColor = AppValues.primaryColor
                (self.splitViewController?.viewControllers[0] as! UINavigationController).navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
                (self.splitViewController?.viewControllers[0] as! UINavigationController).navigationBar.tintColor = AppValues.textColor
            }
            if self.splitViewController?.viewControllers.count != 1 {
                if ((self.splitViewController?.viewControllers[1].isKind(of: UINavigationController.self)) == true) {
                    (self.splitViewController?.viewControllers[1] as! UINavigationController).navigationBar.barTintColor = AppValues.primaryColor
                    (self.splitViewController?.viewControllers[1] as! UINavigationController).navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
                    (self.splitViewController?.viewControllers[1] as! UINavigationController).navigationBar.tintColor = AppValues.textColor
                }
            }
        }
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            setStatusBarStyle(.lightContent)
        }
        else {
            setStatusBarStyle(.default)
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

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            return .lightContent
        }
        else {
            return .default
        }
    }
}
