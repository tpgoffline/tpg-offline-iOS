//
//  LocationSettingsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit

class LocationSettingsTableViewController: UITableViewController {

    let defaults = NSUserDefaults.standardUserDefaults()
    let headers = ["Précision".localized(), "Distance de proximité des arrêts".localized()]
    let choices = [["Normale".localized(), "Précise".localized(), "Très précise".localized()], ["100m".localized(), "200m".localized(), "500m".localized(), "750m".localized(), "1km".localized()]]
    let values = [[0, 1, 2], [100, 200, 500, 750, 1000]]
    var rowSelected = [0,0]
    override func viewDidLoad() {
        super.viewDidLoad()
        rowSelected[0] = values[0].indexOf(defaults.integerForKey("locationAccurency"))!
        if defaults.integerForKey("proximityDistance") == 0 {
            defaults.setInteger(500, forKey: "proximityDistance")
        }
        rowSelected[1] = values[1].indexOf(defaults.integerForKey("proximityDistance"))!
        tableView.backgroundColor = AppValues.primaryColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
		navigationController?.setHistoryBackgroundColor(AppValues.secondaryColor.darkenByPercentage(0.3))
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices[section].count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("choixTabDefaultCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = choices[indexPath.section][indexPath.row]
        cell.selectionStyle = .None
        if indexPath.row == rowSelected[indexPath.section] {
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
        if indexPath.section == 0 {
            defaults.setInteger(values[0][indexPath.row], forKey: "locationAccurency")
        }
        else {
            defaults.setInteger(values[1][indexPath.row], forKey: "proximityDistance")
        }
        rowSelected[indexPath.section] = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView()
        returnedView.backgroundColor = AppValues.secondaryColor
        
        let label = UILabel(frame: CGRect(x: 20, y: 5, width: 500, height: 30))
        label.text = headers[section]
        label.textColor = AppValues.textColor
        returnedView.addSubview(label)
        
        return returnedView
    }
}
