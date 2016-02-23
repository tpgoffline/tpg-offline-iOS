//
//  ItineraireTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
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
	
	let row = [["itineraryCell", FAKIonIcons.logOutIconWithSize(20), "Départ".localized(), "voirArretsItineraire"], ["itineraryCell", FAKIonIcons.logInIconWithSize(20), "Arrivée".localized(), "voirArretsItineraire"], ["itineraryCell", FAKIonIcons.calendarIconWithSize(20), "Date".localized(), "selectDate"], ["itineraryCell", FAKIonIcons.clockIconWithSize(20), "Heure".localized(), "selectHour"], ["switchCell", "Heure de départ".localized(), "Heure d'arrivée".localized()], ["buttonCell", "Rechercher".localized()]]
	
	let headers = ["Recherche".localized(), "Favoris".localized()]
	
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
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if AppValues.favorisItineraires.count == 0 {
			return 1
		}
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return row.count
		}
		else {
			return AppValues.favorisItineraires.count
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			
			if (row[indexPath.row][0] as! String) == "itineraryCell" {
				let cell = tableView.dequeueReusableCellWithIdentifier("itineraryCell", forIndexPath: indexPath)
				cell.textLabel?.text = (row[indexPath.row][2] as! String)
				let image = row[indexPath.row][1] as! FAKIonIcons
				image.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.imageView?.image = image.imageWithSize(CGSize(width: 20, height: 20))
				
				let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
				iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
				
				if (row[indexPath.row][2] as! String) == "Départ".localized() {
					cell.detailTextLabel?.text = ItineraireEnCours.itineraire.depart?.nomComplet
				}
				else if (row[indexPath.row][2] as! String) == "Arrivée".localized() {
					cell.detailTextLabel?.text = ItineraireEnCours.itineraire.arrivee?.nomComplet
				}
				else if (row[indexPath.row][2] as! String) == "Date".localized() && ItineraireEnCours.itineraire.date != nil {
					cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(NSCalendar.currentCalendar().dateFromComponents(ItineraireEnCours.itineraire.date!)!, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
				}
				else if (row[indexPath.row][2] as! String) == "Heure".localized() && ItineraireEnCours.itineraire.date != nil {
					cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(NSCalendar.currentCalendar().dateFromComponents(ItineraireEnCours.itineraire.date!)!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
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
				cell.switchObject.addTarget(self, action: #selector(ItineraireTableViewController.dateArriveeChange(_:)), forControlEvents: .ValueChanged)
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
				cell.button.addTarget(self, action: #selector(ItineraireTableViewController.rechercher(_:)), forControlEvents: .TouchUpInside)
				let view = UIView()
				view.backgroundColor = AppValues.secondaryColor
				cell.selectedBackgroundView = view
				return cell
			}
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("favorisCell", forIndexPath: indexPath) as! FavorisItinerairesTableViewCell
			cell.iconeView.backgroundColor = AppValues.secondaryColor
			
			let iconeItineraire = FAKFontAwesome.starIconWithSize(20)
			iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.iconeImage.image = iconeItineraire.imageWithSize(CGSize(width: 20, height: 20))
			
			var icone = FAKIonIcons.logOutIconWithSize(21)
			icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
			attributedString.appendAttributedString(NSAttributedString(string: " " + (AppValues.favorisItineraires![indexPath.row][0].nomComplet)))
			cell.labelDepart.attributedText = attributedString
			cell.labelDepart.textColor = AppValues.textColor
			cell.labelDepart.backgroundColor = AppValues.primaryColor
			
			let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(20)
			iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.accessoryImage.image = iconCheveron.imageWithSize(CGSize(width: 20, height: 20))
			
			icone = FAKIonIcons.logInIconWithSize(21)
			icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
			attributedString.appendAttributedString(NSAttributedString(string: " " + (AppValues.favorisItineraires![indexPath.row][1].nomComplet)))
			cell.labelArrivee.attributedText = attributedString
			cell.labelArrivee.textColor = AppValues.textColor
			cell.labelArrivee.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.1)
			
			cell.selectionStyle = .None
			
			return cell
		}
	}
	
	func rechercher(sender: AnyObject) {
		if ItineraireEnCours.itineraire.depart != nil && ItineraireEnCours.itineraire.arrivee != nil && ItineraireEnCours.itineraire.date != nil {
			performSegueWithIdentifier("rechercherItineraire", sender: self)
		}
		else {
			let alerte = SCLAlertView()
			alerte.showWarning("Information manquante".localized(), subTitle: "Il manque une information pour rechercher un itinéraire".localized(), closeButtonTitle: "OK".localized(), duration: 10)
		}
	}
	func dateArriveeChange(sender: AnyObject) {
		ItineraireEnCours.itineraire.dateArrivee = !ItineraireEnCours.itineraire.dateArrivee
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 0 {
			performSegueWithIdentifier(row[indexPath.row][3] as! String, sender: self)
		}
		else {
			ItineraireEnCours.itineraire = Itineraire(depart: AppValues.favorisItineraires[indexPath.row][0], arrivee: AppValues.favorisItineraires[indexPath.row][1])
			performSegueWithIdentifier("rechercherItineraire", sender: self)
		}
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let returnedView = UIView()
		returnedView.backgroundColor = AppValues.secondaryColor.darkenByPercentage(0.1)
		
		let label = UILabel(frame: CGRect(x: 20, y: 5, width: 500, height: 30))
		label.text = headers[section]
		label.textColor = AppValues.textColor
		returnedView.addSubview(label)
		
		return returnedView
	}
	
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "voirArretsItineraire" {
			let destinationViewController: tpgArretSelectionTableViewController = (segue.destinationViewController) as! tpgArretSelectionTableViewController
			if (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)?.textLabel?.text == "Départ".localized() ) {
				destinationViewController.depart = true
			}
			else {
				destinationViewController.depart = false
			}
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 44
		}
		else {
			return 88
		}
	}
	
}
