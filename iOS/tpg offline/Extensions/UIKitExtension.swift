//
//  UIKitExtension.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Chameleon
import FontAwesomeKit

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
            UIApplication.shared.statusBarStyle = .lightContent
        }
        else {
            UIApplication.shared.statusBarStyle = .default
        }
        
        let iconeHorloge = FAKIonIcons.iosClockIcon(withSize: 20)!
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        var iconImage = iconeHorloge.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![0].image = iconImage
        tabBarController!.tabBar.items![0].selectedImage = iconImage
        
        let iconeAttention = FAKFontAwesome.warningIcon(withSize: 20)!
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconeAttention.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![1].image = iconImage
        tabBarController!.tabBar.items![1].selectedImage = iconImage
        
        let iconeItineraire = FAKFontAwesome.mapSignsIcon(withSize: 20)!
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconeItineraire.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![2].image = iconImage
        tabBarController!.tabBar.items![2].selectedImage = iconImage
        
        let iconePlan = FAKFontAwesome.mapIcon(withSize: 20)!
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconePlan.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![3].image = iconImage
        tabBarController!.tabBar.items![3].selectedImage = iconImage
        
        let iconeParametre = FAKFontAwesome.cogIcon(withSize: 20)!
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        iconImage = iconeParametre.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![4].image = iconImage
        tabBarController!.tabBar.items![4].selectedImage = iconImage
    }
}

extension UITableViewController {
    override func refreshTheme() {
        super.refreshTheme()
        
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
    }
}
