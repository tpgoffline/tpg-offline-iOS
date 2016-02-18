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
    static var json: JSON!
	static var canFavorite: Bool!
}

class ItineraireTableViewController: UITableViewController {
    let row = [["itineraryCell", FAKIonIcons.logOutIconWithSize(20), "Départ", "voirArretsItineraire"], ["itineraryCell", FAKIonIcons.logInIconWithSize(20), "Arrivée", "voirArretsItineraire"], ["itineraryCell", FAKIonIcons.calendarIconWithSize(20), "Date", "selectDate"], ["itineraryCell", FAKIonIcons.clockIconWithSize(20), "Heure", "selectHour"], ["switchCell", "Heure de départ", "Heure d'arrivée"], ["buttonCell", "Rechercher"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        ItineraireEnCours.itineraire = Itineraire(depart: nil, arrivee: nil, date: NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate()), dateArrivee: false)
        
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		
		ItineraireEnCours.canFavorite = true
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        tableView.backgroundColor = AppValues.primaryColor
        
        tableView.reloadData()
		
		ItineraireEnCours.itineraire.id = NSUUID()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}
        return row.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("itineraryCell", forIndexPath: indexPath)
			cell.textLabel?.text = "Favoris"
			cell.detailTextLabel?.text = ""
			let image = FAKFontAwesome.starIconWithSize(20)
			image.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.imageView?.image = image.imageWithSize(CGSize(width: 20, height: 20))
			cell.textLabel?.textColor = AppValues.textColor
			cell.detailTextLabel?.textColor = AppValues.textColor
			cell.backgroundColor = AppValues.primaryColor
			
			let view = UIView()
			view.backgroundColor = AppValues.secondaryColor
			cell.selectedBackgroundView = view
			return cell
		}
        if (row[indexPath.row][0] as! String) == "itineraryCell" {
            let cell = tableView.dequeueReusableCellWithIdentifier("itineraryCell", forIndexPath: indexPath)
            cell.textLabel?.text = (row[indexPath.row][2] as! String)
            let image = row[indexPath.row][1] as! FAKIonIcons
            image.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = image.imageWithSize(CGSize(width: 20, height: 20))
            
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
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
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.backgroundColor = AppValues.primaryColor
            
            let view = UIView()
            view.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = view
            return cell
        }
        else if (row[indexPath.row][0] as! String) == "switchCell" {
            let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as! SwitchTableViewCell
            cell.switchObject.leftTitle = row[indexPath.row][1] as! String
            cell.switchObject.rightTitle = row[indexPath.row][2] as! String
            cell.switchObject.backgroundColor = AppValues.primaryColor.lightenByPercentage(0.1)
            cell.switchObject.selectedBackgroundColor = AppValues.secondaryColor.darkenByPercentage(0.1)
            cell.switchObject.titleColor = AppValues.textColor
            cell.switchObject.selectedTitleColor = AppValues.textColor
            if ItineraireEnCours.itineraire.dateArrivee == true {
                cell.switchObject.setSelectedIndex(1, animated: true)
            }
            cell.switchObject.addTarget(self, action: "dateArriveeChange:", forControlEvents: .ValueChanged)
            cell.backgroundColor = AppValues.primaryColor
            let view = UIView()
            view.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = view
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("buttonCell", forIndexPath: indexPath) as! ButtonTableViewCell
            cell.button.setTitle((row[indexPath.row][1] as! String), forState: .Normal)
            cell.button.backgroundColor = AppValues.secondaryColor
            cell.button.tintColor = AppValues.textColor
            cell.button.addTarget(self, action: "rechercher:", forControlEvents: .TouchUpInside)
            let view = UIView()
            view.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = view
            return cell
        }
    }
   
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 0 {
			performSegueWithIdentifier("showFavorisItineraire", sender: self)
		}
		else {
			performSegueWithIdentifier(row[indexPath.row][3] as! String, sender: self)
		}
    }
	
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
