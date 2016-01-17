//
//  VueItineraireTableViewController.swift
//  tpg offline
//
//  Created by Alice on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView

class VueItineraireTableViewController: UITableViewController {
    var itineraire: JSON! = []
    var compteur = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        var url = "http://transport.opendata.ch/v1/connections?"
        url += "from=" + ItineraireEnCours.itineraire.depart!.idTransportAPI
        url += "&to=" + ItineraireEnCours.itineraire.arrivee!.idTransportAPI
        url += "&date=" + String(ItineraireEnCours.itineraire.date!.year) + "-" + String(ItineraireEnCours.itineraire.date!.month) + "-" + String(ItineraireEnCours.itineraire.date!.day)
        url += "&time=" + String(ItineraireEnCours.itineraire.date!.hour) + ":" + String(ItineraireEnCours.itineraire.date!.minute)
        url += "&isArrivalTime=" + String(Int(ItineraireEnCours.itineraire.dateArrivee))
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            itineraire = JSON(data: data)
        }
        else {
            let alerte = SCLAlertView()
            alerte.showError("Pas d'interent", subTitle: "Vous devez être connecté à internet pour construire un itinéraire", closeButtonTitle: "OK", duration: 10).setDismissBlock({ () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKIonIcons.iosArrowRightIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itineraireSuivant:")]
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
        return itineraire["connections"][compteur]["sections"].count
    }
    
    func itineraireSuivant(sender: AnyObject!) {
        if itineraire["connections"].count > compteur + 1 {
            compteur++
            tableView.reloadData()
        }
        if itineraire["connections"].count - 1 == compteur {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKIonIcons.iosArrowLeftIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itinerairePrecedent:")]
        }
        else {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKIonIcons.iosArrowRightIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itineraireSuivant:"), UIBarButtonItem(image: FAKIonIcons.iosArrowLeftIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itinerairePrecedent:")]
        }
    }
    func itinerairePrecedent(sender: AnyObject!) {
        if compteur - 1 >= 0 {
            compteur--
            tableView.reloadData()
        }
        if compteur == 0 {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKIonIcons.iosArrowRightIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itineraireSuivant:")]
        }
        else {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKIonIcons.iosArrowRightIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itineraireSuivant:"), UIBarButtonItem(image: FAKIonIcons.iosArrowLeftIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "itinerairePrecedent:")]
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itineraireCell", forIndexPath: indexPath) as! ItineraireTableViewCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.flatOrangeColorDark()
        cell.selectedBackgroundView = backgroundView
        
        if itineraire["connections"][compteur]["sections"][indexPath.row]["walk"].type == .Null {
            if itineraire["connections"][compteur]["sections"][indexPath.row]["journey"]["categoryCode"].intValue == 6 {
                let icone = FAKIonIcons.androidBusIconWithSize(40)
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 40, height: 40))
            }
            else if itineraire["connections"][compteur]["sections"][indexPath.row]["journey"]["categoryCode"].intValue == 4 {
                let icone = FAKIonIcons.androidBoatIconWithSize(40)
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 40, height: 40))
            }
            else if itineraire["connections"][compteur]["sections"][indexPath.row]["journey"]["categoryCode"].intValue == 9 {
                let icone = FAKIonIcons.androidSubwayIconWithSize(40)
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 40, height: 40))
            }
            else {
                let icone = FAKIonIcons.androidTrainIconWithSize(40)
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 40, height: 40))
            }
            cell.ligneLabel.text = itineraire["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue
            cell.directionLabel.text = "Direction " + itineraire["connections"][compteur]["sections"][indexPath.row]["journey"]["to"].stringValue
        }
        else {
            let icone = FAKIonIcons.androidWalkIconWithSize(40)
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 40, height: 40))
            cell.ligneLabel.text = "Marche"
            cell.directionLabel.text = itineraire["connections"][compteur]["sections"][indexPath.row]["walk"]["duration"].stringValue.characters.split(":").map(String.init)[1] + " minute(s)"
        }
        
        cell.departLabel.text = "De : " + itineraire["connections"][compteur]["sections"][indexPath.row]["departure"]["station"]["name"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var timestamp = itineraire["connections"][compteur]["sections"][indexPath.row]["departure"]["departureTimestamp"].intValue
        cell.heureDepartLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        timestamp = itineraire["connections"][compteur]["sections"][indexPath.row]["arrival"]["arrivalTimestamp"].intValue
        cell.arriveeLabel.text = "A : " + itineraire["connections"][compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue
        cell.heureArriveeLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))

        
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
