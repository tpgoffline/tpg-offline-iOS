//
//  UIKitExtension.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework

extension UIViewController {
	func actualiserTheme() {
		navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
		navigationController?.navigationBar.tintColor = AppValues.textColor
		view.backgroundColor = AppValues.primaryColor
		
		if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
			UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
		}
		else {
			UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
		}
	}
}

extension UITableViewController {
	override func actualiserTheme() {
		super.actualiserTheme()
		
		tableView.backgroundColor = AppValues.primaryColor
		tableView.reloadData()
	}
}