//
//  ItineraireTableViewController.swift
//  tpg offline
//
//  Created by Alice on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import DGRunkeeperSwitch
import SCLAlertView

struct ItineraireEnCours {
    static var itineraire: Itineraire!
}

class ItineraireTableViewController: UITableViewController {
    let row = [["itineraryCell", FAKIonIcons.logOutIconWithSize(20), "Départ", "voirArretsItineraire"], ["itineraryCell", FAKIonIcons.logInIconWithSize(20), "Arrivée", "voirArretsItineraire"], ["itineraryCell", FAKIonIcons.calendarIconWithSize(20), "Date", "selectDate"], ["itineraryCell", FAKIonIcons.clockIconWithSize(20), "Heure", "selectHour"], ["switchCell", "Heure de départ", "Heure d'arrivée"], ["buttonCell", "Rechercher"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        ItineraireEnCours.itineraire = Itineraire(depart: nil, arrivee: nil, date: nil, dateArrivee: false)
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(ItineraireEnCours.itineraire.date)
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return row.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (row[indexPath.row][0] as! String) == "itineraryCell" {
            let cell = tableView.dequeueReusableCellWithIdentifier("itineraryCell", forIndexPath: indexPath)
            cell.textLabel?.text = (row[indexPath.row][2] as! String)
            let image = row[indexPath.row][1] as! FAKIonIcons
            image.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.imageView?.image = image.imageWithSize(CGSize(width: 20, height: 20))
            
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            
            if (row[indexPath.row][2] as! String) == "Départ" {
                cell.detailTextLabel?.text = ItineraireEnCours.itineraire.depart?.nomComplet
            }
            else if (row[indexPath.row][2] as! String) == "Arrivée" {
                cell.detailTextLabel?.text = ItineraireEnCours.itineraire.arrivee?.nomComplet
            }
            else if (row[indexPath.row][2] as! String) == "Date" && ItineraireEnCours.itineraire.date != nil {
                cell.detailTextLabel?.text = String(ItineraireEnCours.itineraire.date!.day) + "/" + String(ItineraireEnCours.itineraire.date!.month) + "/" + String(ItineraireEnCours.itineraire.date!.year)
            }
            else if (row[indexPath.row][2] as! String) == "Heure" && ItineraireEnCours.itineraire.date != nil {
                if ItineraireEnCours.itineraire.date!.minute < 10 {
                    cell.detailTextLabel?.text = String(ItineraireEnCours.itineraire.date!.hour) + ":0" +
                        String(ItineraireEnCours.itineraire.date!.minute)
                }
                else {
                    cell.detailTextLabel?.text = String(ItineraireEnCours.itineraire.date!.hour) + ":" + String(ItineraireEnCours.itineraire.date!.minute)
                }
                
            }
            else {
                cell.detailTextLabel?.text = ""
            }
            return cell
        }
        else if (row[indexPath.row][0] as! String) == "switchCell" {
            let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as! SwitchTableViewCell
            cell.switchObject.leftTitle = row[indexPath.row][1] as! String
            cell.switchObject.rightTitle = row[indexPath.row][2] as! String
            cell.switchObject.backgroundColor = UIColor.flatOrangeColor()
            cell.switchObject.selectedBackgroundColor = UIColor.flatOrangeColorDark()
            cell.switchObject.titleColor = UIColor.whiteColor()
            cell.switchObject.selectedTitleColor = UIColor.whiteColor()
            if ItineraireEnCours.itineraire.dateArrivee == true {
                cell.switchObject.setSelectedIndex(1, animated: true)
            }
            cell.switchObject.addTarget(self, action: "dateArriveeChange:", forControlEvents: .ValueChanged)
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("buttonCell", forIndexPath: indexPath) as! ButtonTableViewCell
            cell.button.setTitle((row[indexPath.row][1] as! String), forState: .Normal)
            cell.button.backgroundColor = UIColor.flatGreenColorDark()
            cell.button.tintColor = UIColor.whiteColor()
            cell.button.addTarget(self, action: "rechercher:", forControlEvents: .TouchUpInside)
            return cell
        }
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
    func rechercher(sender: AnyObject) {
        if ItineraireEnCours.itineraire.depart != nil && ItineraireEnCours.itineraire.arrivee != nil && ItineraireEnCours.itineraire.date != nil {
            performSegueWithIdentifier("rechercherItineraire", sender: self)
        }
        else {
            let alerte = SCLAlertView()
            alerte.showWarning("Information manquante", subTitle: "Il manque une information pour rechercher un itinéraire", closeButtonTitle: "OK", duration: 10)
        }
    }
    func dateArriveeChange(sender: AnyObject) {
        ItineraireEnCours.itineraire.dateArrivee = !ItineraireEnCours.itineraire.dateArrivee
    }
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(row[indexPath.row][3] as! String, sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "voirArretsItineraire" {
            let destinationViewController: tpgArretSelectionTableViewController = (segue.destinationViewController) as! tpgArretSelectionTableViewController
            if (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)?.textLabel?.text == "Départ" ) {
                destinationViewController.depart = true
            }
            else {
                destinationViewController.depart = false
            }
        }
    }
    

}
