//
//  ListeItinerairesTableViewController.swift
//  tpg offline
//
//  Created by Alice on 19/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView

class ListeItinerairesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var url = "http://transport.opendata.ch/v1/connections?"
        url += "from=" + ItineraireEnCours.itineraire.depart!.idTransportAPI
        url += "&to=" + ItineraireEnCours.itineraire.arrivee!.idTransportAPI
        url += "&date=" + String(ItineraireEnCours.itineraire.date!.year) + "-" + String(ItineraireEnCours.itineraire.date!.month) + "-" + String(ItineraireEnCours.itineraire.date!.day)
        url += "&time=" + String(ItineraireEnCours.itineraire.date!.hour) + ":" + String(ItineraireEnCours.itineraire.date!.minute)
        url += "&isArrivalTime=" + String(Int(ItineraireEnCours.itineraire.dateArrivee))
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            ItineraireEnCours.json = JSON(data: data)
        }
        else {
            let alerte = SCLAlertView()
            alerte.showError("Pas d'interent", subTitle: "Vous devez être connecté à internet pour construire un itinéraire. Si vous êtes connecté à internet, le serveur est peut-être indisponible.", closeButtonTitle: "OK", duration: 10).setDismissBlock({ () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }

        
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItineraireEnCours.json["connections"].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listeItineaireCell", forIndexPath: indexPath) as! ListeItinerairesTableViewCell

        var icone = FAKIonIcons.logOutIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())

        var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][indexPath.row]["from"]["station"]["name"].stringValue))
        cell.labelDepart.attributedText = attributedString

        icone = FAKIonIcons.logInIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        
        attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][indexPath.row]["to"]["station"]["name"].stringValue))
        cell.labelArrivee.attributedText = attributedString
        
        icone = FAKIonIcons.clockIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        
        attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + String(ItineraireEnCours.json["connections"][indexPath.row]["duration"].stringValue.characters.dropFirst().dropFirst().dropFirst())))
        cell.labelDuree.attributedText = attributedString
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var timestamp = ItineraireEnCours.json["connections"][indexPath.row]["from"]["departureTimestamp"].intValue
        cell.labelHeureDepart.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        
        timestamp = ItineraireEnCours.json["connections"][indexPath.row]["to"]["arrivalTimestamp"].intValue
        cell.labelHeureArrivee.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "voirItineraire" {
            let destinationViewController: VueItineraireTableViewController = (segue.destinationViewController) as! VueItineraireTableViewController
            destinationViewController.compteur = (tableView.indexPathForSelectedRow?.row)!
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
