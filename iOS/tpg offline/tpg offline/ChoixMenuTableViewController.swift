//
//  ChoixMenuTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 20/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import Google

class ChoixMenuTableViewController: UITableViewController {
    let defaults = NSUserDefaults.standardUserDefaults()
    var rowSelected = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        rowSelected = defaults.integerForKey("selectedTabBar")
        tableView.backgroundColor = AppValues.primaryColor
     
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        actualiserTheme()
		
		if !(NSProcessInfo.processInfo().arguments.contains("-withoutAnalytics")) {
			let tracker = GAI.sharedInstance().defaultTracker
			tracker.set(kGAIScreenName, value: "ChoixMenuTableViewController")
			tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]!)
		}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabBarController!.tabBar.items!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("choixTabDefaultCell", forIndexPath: indexPath)

        cell.imageView?.image = tabBarController!.tabBar.items![indexPath.row].image
        cell.textLabel?.text = tabBarController!.tabBar.items![indexPath.row].title
        cell.selectionStyle = .None
        if indexPath.row == rowSelected {
            let iconOk = FAKFontAwesome.checkIconWithSize(20)
            iconOk.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.accessoryView = UIImageView(image: iconOk.imageWithSize(CGSize(width: 20, height: 20)))
        }
        else {
            cell.accessoryView = nil
        }
        cell.textLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defaults.setInteger(indexPath.row, forKey: "selectedTabBar")
        rowSelected = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }
}
