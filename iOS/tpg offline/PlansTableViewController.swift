//
//  PlansTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import ChameleonFramework

class PlansTableViewController: UITableViewController {
	let listePlans = ["Plan urbain", "Plan périurbain", "Plan noctambus urbain", "Plan noctambus régional"]
	override func viewDidLoad() {
		super.viewDidLoad()
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .AllVisible
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		actualiserTheme()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return listePlans.count
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("plansCell", forIndexPath: indexPath)
		
		cell.textLabel?.text = listePlans[indexPath.row].localized()
		cell.textLabel?.textColor = AppValues.textColor
		cell.backgroundColor = AppValues.primaryColor
		
		return cell
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "afficherPlan" {
            let nav = segue.destinationViewController as! UINavigationController
			let planViewController = nav.viewControllers[0] as! PlanViewController
			planViewController.image = UIImage(named: listePlans[(tableView.indexPathForSelectedRow?.row)!])
			planViewController.titre = listePlans[(tableView.indexPathForSelectedRow?.row)!]
		}
	}
	
	
}

extension PlansTableViewController : UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}