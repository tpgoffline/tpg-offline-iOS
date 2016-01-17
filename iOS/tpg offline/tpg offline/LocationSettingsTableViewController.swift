//
//  LocationSettingsTableViewController.swift
//  tpg offline
//
//  Created by Alice on 11/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit

class LocationSettingsTableViewController: UITableViewController {

    let defaults = NSUserDefaults.standardUserDefaults()
    let headers = ["Précision", "Distance de proximité d'arrets"]
    let choices = [["Normale", "Précise", "Très précise"], ["100m", "200m", "500m", "750m", "1km"]]
    let values = [[0, 1, 2], [100, 200, 500, 750, 1000]]
    var rowSelected = [0,0]
    override func viewDidLoad() {
        super.viewDidLoad()
        rowSelected[0] = values[0].indexOf(defaults.integerForKey("locationAccurency"))!
        if defaults.integerForKey("proximityDistance") == 0 {
            defaults.setInteger(500, forKey: "proximityDistance")
        }
        rowSelected[1] = values[1].indexOf(defaults.integerForKey("proximityDistance"))!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return choices[section].count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
 
    /*override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
*/
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("choixTabDefaultCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = choices[indexPath.section][indexPath.row]
        cell.selectionStyle = .None
        if indexPath.row == rowSelected[indexPath.section] {
            let iconOk = FAKFontAwesome.checkIconWithSize(20)
            iconOk.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.accessoryView = UIImageView(image: iconOk.imageWithSize(CGSize(width: 20, height: 20)))
        }
        else {
            cell.accessoryView = nil
        }
        
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
        returnedView.backgroundColor = UIColor.flatOrangeColorDark()
        
        let label = UILabel(frame: CGRect(x: 20, y: 5, width: 500, height: 30))
        label.text = headers[section]
        label.textColor = UIColor.whiteColor()
        returnedView.addSubview(label)
        
        return returnedView
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
