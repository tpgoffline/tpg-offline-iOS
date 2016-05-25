//
//  RoutesTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesomeKit
import DGRunkeeperSwitch
import SCLAlertView

struct ActualRoutes {
	static var route: SearchRoute! = SearchRoute(departure: nil, arrival: nil, date: NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate()), isArrivalDate: false)
	static var canFavorite: Bool! = false
    static var routeResult: [Route]! = []
}

class RoutesTableViewController: UITableViewController {
	
	let row = [
        ["itineraryCell", FAKIonIcons.logOutIconWithSize(20), "Départ".localized(), "voirArretsItineraire"],
        ["itineraryCell", FAKIonIcons.logInIconWithSize(20), "Arrivée".localized(), "voirArretsItineraire"],
        ["itineraryCell", FAKIonIcons.calendarIconWithSize(20), "Date".localized(), "selectDate"],
        ["itineraryCell", FAKIonIcons.clockIconWithSize(20), "Heure".localized(), "selectHour"],
        ["switchCell", "Heure de départ".localized(), "Heure d'arrivée".localized()],
        ["buttonCell", "Rechercher".localized()]]
	
	let headers = ["Recherche".localized(), "Favoris".localized()]
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .AllVisible
        
        var barButtonsItems: [UIBarButtonItem] = []
        let exchangeIcon = FAKFontAwesome.exchangeIconWithSize(20)
        barButtonsItems.append(UIBarButtonItem(image: exchangeIcon.imageWithSize(CGSize(width: 20, height: 20)), style: .Done, target: self, action: #selector(RoutesTableViewController.echangerArrets)))
        navigationItem.leftBarButtonItems = barButtonsItems
	}
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		ActualRoutes.canFavorite = true
		refreshTheme()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
    func echangerArrets() {
        let arretDepart = ActualRoutes.route.departure
        let arretArrivee = ActualRoutes.route.arrival
        ActualRoutes.route.departure = arretArrivee
        ActualRoutes.route.arrival = arretDepart
        tableView.reloadData()
    }
    
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if AppValues.favoritesRoutes.count == 0 {
			return 1
		}
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return row.count
		}
		else {
			return AppValues.favoritesRoutes.count
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
					cell.detailTextLabel?.text = ActualRoutes.route.departure?.fullName
				}
				else if (row[indexPath.row][2] as! String) == "Arrivée".localized() {
					cell.detailTextLabel?.text = ActualRoutes.route.arrival?.fullName
				}
				else if (row[indexPath.row][2] as! String) == "Date".localized() && ActualRoutes.route.date != nil {
					cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(NSCalendar.currentCalendar().dateFromComponents(ActualRoutes.route.date!)!, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
				}
				else if (row[indexPath.row][2] as! String) == "Heure".localized() && ActualRoutes.route.date != nil {
					cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(NSCalendar.currentCalendar().dateFromComponents(ActualRoutes.route.date!)!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
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
				if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
					cell.switchObject.backgroundColor = AppValues.primaryColor.lightenByPercentage(0.1)
					cell.switchObject.selectedBackgroundColor = AppValues.secondaryColor.darkenByPercentage(0.1)
				}
				else {
					cell.switchObject.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.1)
					cell.switchObject.selectedBackgroundColor = AppValues.secondaryColor.lightenByPercentage(0.1)
				}
				
				cell.switchObject.titleColor = AppValues.textColor
				cell.switchObject.selectedTitleColor = AppValues.textColor
				if ActualRoutes.route.isArrivalDate == true {
					cell.switchObject.setSelectedIndex(1, animated: true)
				}
				cell.switchObject.addTarget(self, action:#selector(RoutesTableViewController.dateArriveeChange(_:)), forControlEvents: .ValueChanged)
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
				cell.button.addTarget(self, action: #selector(RoutesTableViewController.rechercher(_:)), forControlEvents: .TouchUpInside)
                cell.backgroundColor = AppValues.secondaryColor
				let view = UIView()
				view.backgroundColor = AppValues.secondaryColor
				cell.selectedBackgroundView = view
				return cell
			}
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("favorisCell", forIndexPath: indexPath) as! FavoriteRouteTableViewCell
			cell.iconView.backgroundColor = AppValues.secondaryColor
			
			let starIcon = FAKFontAwesome.starIconWithSize(20)
			starIcon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.iconImageView.image = starIcon.imageWithSize(CGSize(width: 20, height: 20))
			
			var icon = FAKIonIcons.logOutIconWithSize(21)
			icon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			var attributedString = NSMutableAttributedString(attributedString: icon.attributedString())
			attributedString.appendAttributedString(NSAttributedString(string: " " + (AppValues.favoritesRoutes![indexPath.row][0].fullName)))
			cell.departureLabel.attributedText = attributedString
			cell.departureLabel.textColor = AppValues.textColor
			cell.departureLabel.backgroundColor = AppValues.primaryColor
			
			let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(20)
			iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.accessoryImage.image = iconCheveron.imageWithSize(CGSize(width: 20, height: 20))
			
			icon = FAKIonIcons.logInIconWithSize(21)
			icon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			attributedString = NSMutableAttributedString(attributedString: icon.attributedString())
			attributedString.appendAttributedString(NSAttributedString(string: " " + (AppValues.favoritesRoutes![indexPath.row][1].fullName)))
			cell.arrivalLabel.attributedText = attributedString
			cell.arrivalLabel.textColor = AppValues.textColor
			cell.arrivalLabel.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.1)
			
			cell.selectionStyle = .None
			
			return cell
		}
	}
	
	func rechercher(sender: AnyObject) {
		if ActualRoutes.route.departure != nil && ActualRoutes.route.arrival != nil && ActualRoutes.route.date != nil {

			performSegueWithIdentifier("rechercherItineraire", sender: self)
		}
		else {
			let alert = SCLAlertView()
			alert.showWarning("Information manquante".localized(), subTitle: "Il manque une information pour rechercher un itinéraire".localized(), closeButtonTitle: "OK".localized(), duration: 10)
		}
	}
	func dateArriveeChange(sender: AnyObject) {
		ActualRoutes.route.isArrivalDate = !ActualRoutes.route.isArrivalDate
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 1 {
			ActualRoutes.route = SearchRoute(departure: AppValues.favoritesRoutes[indexPath.row][0], arrival: AppValues.favoritesRoutes[indexPath.row][1])
			performSegueWithIdentifier("rechercherItineraire", sender: self)
		}
		else if (row[indexPath.row][0] as! String) == "itineraryCell" {
			performSegueWithIdentifier(row[indexPath.row][3] as! String, sender: self)
		}
		else {
			tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
			let destinationViewController = segue.destinationViewController as! RoutesStopsTableViewController
			if (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)?.textLabel?.text == "Départ".localized() ) {
				destinationViewController.departure = true
			}
			else {
				destinationViewController.departure = false
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

extension RoutesTableViewController: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}