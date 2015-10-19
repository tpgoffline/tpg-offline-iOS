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
        print(url, appendNewline: true)
        let data = NSData(contentsOfURL: url)!
        self.xmlArret = SWXMLHash.lazy(data)
        nombreSections = [xmlArret["nextDepartures"]["stop"]["connections"]["connection"].all.count, xmlArret["nextDepartures"]["departures"]["departure"].all.count]
        
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("arrettableviewcell", forIndexPath: indexPath) as! ArretTableViewCell
        if indexPath.section == 0 {
            cell.labeltempsProchainDepart.hidden = true
            let nomImageLigne = "Picto " + (xmlArret["nextDepartures"]["stop"]["connections"]["connection"][indexPath.item]["lineCode"].element?.text)!
            cell.labelDirection.text = (xmlArret["nextDepartures"]["stop"]["connections"]["connection"][indexPath.item]["destinationName"].element?.text)!
            cell.imageLigne.image = UIImage(named: nomImageLigne)
            if cell.imageLigne.image == nil {
                cell.imageLigne.image = UIImage(named: "Picto ?")
            }
        }
        else if indexPath.section == 1 {
            switch xmlArret["nextDepartures"]["stop"]["connections"]["connection"][indexPath.row]["destinationName"] {
            case .Element(_):
                if (xmlArret["nextDepartures"]["departures"]["departure"][indexPath.row]["waitingTime"].element?.text)! == "&gt;1h" {
                    let texte = ">1h"
                    cell.labeltempsProchainDepart.text = texte
                }
                else {
                    var texte = (xmlArret["nextDepartures"]["departures"]["departure"][indexPath.row]["waitingTime"].element?.text)!
                    texte += " min"
                    cell.labeltempsProchainDepart.text = texte
                }
            case .Error(let error):
                print(error.localizedDescription, appendNewline: true)
            default:
                print("", appendNewline: false)
            }
            cell.labeltempsProchainDepart.hidden = false
            //let nomImageLigne = "Picto " + (xmlArret["nextDepartures"]["departures"]["departure"][indexPath.item]["connection"]["lineCode"].element?.text)!
            //cell.labelDirection.text = (xmlArret["nextDepartures"]["stop"]["connections"]["connection"][indexPath.row]["destinationName"].element?.text)!
            //cell.imageLigne.image = UIImage(named: nomImageLigne)
            //if cell.imageLigne.image == nil {
            //    cell.imageLigne.image = UIImage(named: "Picto ?")
            //}
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            switch xmlArret["nextDepartures"]["departures"]["departure"][indexPath.row]["timestamp"] {
            case .Element(_):
                if (xmlArret["nextDepartures"]["departures"]["departure"][indexPath.row]["waitingTime"].element?.text)! == "&gt;1h" {
                    let texte = ">1h"
                    cell.labeltempsProchainDepart.text = texte
                }
                else {
                    var texte = (xmlArret["nextDepartures"]["departures"]["departure"][indexPath.row]["waitingTime"].element?.text)!
                    texte += " min"
                    cell.labeltempsProchainDepart.text = texte
                }
            case .Error( _):
                cell.labeltempsProchainDepart.hidden = true
            default:
                print("", appendNewline: false)
            }
            
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
