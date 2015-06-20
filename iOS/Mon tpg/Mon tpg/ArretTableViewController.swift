//
//  ArretTableViewController.swift
//  Mon tpg
//
//  Created by remy on 13/06/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class ArretTableViewController: UITableViewController {
    
    var arret = ""
    var arretCode = ""
    var listeDepart = [XMLIndexer]()
    var xmlArret:XMLIndexer! = nil
    var tpgURLConstruct: tpgURLconstruct!
    
    var titreSections = ["Directions","Prochains départs"]
    var nombreSections = [0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tpgURLConstruct = tpgURLconstruct(cleAPI: "d95be980-0830-11e5-a039-0002a5d5c51b")
        let url = NSURL(string: tpgURLConstruct.getNextDeparturesURL(arretCode))!
        let data = NSData(contentsOfURL: url)!
        self.xmlArret = SWXMLHash.lazy(data)
        nombreSections = [xmlArret["nextDepartures"]["stop"]["connections"]["connection"].all.count, xmlArret["nextDepartures"]["stop"]["departures"]["departure"].all.count]
        
        
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
        return nombreSections[section]
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titreSections[section]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell()
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("direction", forIndexPath: indexPath)
        }
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("depart", forIndexPath: indexPath)
        }

        // Configure the cell...

        return cell
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
        // Return NO if you do not want the item to be re-orderable.
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
