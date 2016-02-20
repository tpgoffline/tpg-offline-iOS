//
//  PlansTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework

class PlansTableViewController: UITableViewController {
    let listePlans = ["Plan urbain", "Plan périurbain", "Plan noctambus urbain", "Plan noctambus régional"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        
        tableView.backgroundColor = AppValues.primaryColor
        
        tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listePlans.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("plansCell", forIndexPath: indexPath)

        cell.textLabel?.text = listePlans[indexPath.row]
        cell.textLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor

        return cell
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "afficherPlan" {
            let planViewController: PlanViewController = (segue.destinationViewController) as! PlanViewController
            planViewController.image = UIImage(named: listePlans[(tableView.indexPathForSelectedRow?.row)!])
        }
    }
    

}
