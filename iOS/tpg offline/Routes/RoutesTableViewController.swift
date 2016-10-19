//
//  RoutesTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Chameleon
import SCLAlertView
import FontAwesomeKit

struct ActualRoutes {
	static var route: SearchRoute! = SearchRoute(departure: nil, arrival: nil, date: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: Date()), isArrivalDate: false)
	static var canFavorite: Bool! = false
    static var routeResult: [Route]! = []
}

class RoutesTableViewController: UITableViewController {
	
	let row = [
        ["itineraryCell", FAKIonIcons.logOutIcon(withSize: 20)!, "Départ".localized(), "voirArretsItineraire"],
        ["itineraryCell", FAKIonIcons.logInIcon(withSize: 20)!, "Arrivée".localized(), "voirArretsItineraire"],
        ["itineraryCell", FAKIonIcons.calendarIcon(withSize: 20)!, "Date".localized(), "selectDate"],
        ["itineraryCell", FAKIonIcons.clockIcon(withSize: 20)!, "Heure".localized(), "selectHour"],
        ["switchCell", "Heure de départ".localized(), "Heure d'arrivée".localized()],
        ["buttonCell", "Rechercher".localized()]]
	
	let headers = ["Recherche".localized(), "Favoris".localized()]
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
        
        var barButtonsItems: [UIBarButtonItem] = []
        let exchangeIcon = FAKFontAwesome.exchangeIcon(withSize: 20)!
        barButtonsItems.append(UIBarButtonItem(image: exchangeIcon.image(with: CGSize(width: 20, height: 20)), style: .done, target: self, action: #selector(RoutesTableViewController.echangerArrets)))
        navigationItem.leftBarButtonItems = barButtonsItems
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		refreshTheme()
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
    
	override func numberOfSections(in tableView: UITableView) -> Int {
		if AppValues.favoritesRoutes.count == 0 {
			return 1
		}
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return row.count
		}
		else {
			return AppValues.favoritesRoutes.count
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (indexPath as NSIndexPath).section == 0 {
			
			if (row[indexPath.row][0] as! String) == "itineraryCell" {
				let cell = tableView.dequeueReusableCell(withIdentifier: "itineraryCell", for: indexPath)
                
				cell.textLabel?.text = (row[indexPath.row][2] as! String)
                
				let image = row[indexPath.row][1] as! FAKIonIcons
				image.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.imageView?.image = image.image(with: CGSize(width: 20, height: 20))
				
				let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 15)!
				iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.accessoryView = UIImageView(image: iconCheveron.image(with: CGSize(width: 20, height: 20)))
				
				if (row[indexPath.row][2] as! String) == "Départ".localized() {
					cell.detailTextLabel?.text = ActualRoutes.route.departure?.fullName
				}
				else if (row[indexPath.row][2] as! String) == "Arrivée".localized() {
					cell.detailTextLabel?.text = ActualRoutes.route.arrival?.fullName
				}
				else if (row[indexPath.row][2] as! String) == "Date".localized() && ActualRoutes.route.date != nil {
					cell.detailTextLabel?.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
				}
				else if (row[indexPath.row][2] as! String) == "Heure".localized() && ActualRoutes.route.date != nil {
					cell.detailTextLabel?.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
				}
				else {
					cell.detailTextLabel?.text = ""
				}
				cell.textLabel?.textColor = AppValues.textColor
				cell.detailTextLabel?.textColor = AppValues.textColor
				cell.backgroundColor = AppValues.primaryColor
				
				let view = UIView()
				view.backgroundColor = AppValues.primaryColor
				cell.selectedBackgroundView = view
				return cell
			}
			else if (row[indexPath.row][0] as! String) == "switchCell" {
				let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
                cell.switchObject.titles = [row[indexPath.row][1] as! String, row[indexPath.row][2] as! String]
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.switchObject.backgroundColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
                    cell.switchObject.selectedBackgroundColor = AppValues.primaryColor.darken(byPercentage: 0.1)
                }
                else {
                    cell.switchObject.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.1)
                    cell.switchObject.selectedBackgroundColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
                }
                
                cell.switchObject.titleColor = AppValues.textColor
                cell.switchObject.selectedTitleColor = AppValues.textColor
                if ActualRoutes.route.isArrivalDate == true {
                    cell.switchObject.setSelectedIndex(1, animated: false)
                }
                else {
                    cell.switchObject.setSelectedIndex(0, animated: false)
                }
                cell.switchObject.autoresizingMask = [.flexibleWidth]
				cell.switchObject.addTarget(self, action:#selector(RoutesTableViewController.dateArriveeChange(_:)), for: .valueChanged)
				cell.backgroundColor = AppValues.primaryColor
				let view = UIView()
				view.backgroundColor = AppValues.primaryColor
				cell.selectedBackgroundView = view
				return cell
			}
			else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell
				cell.button.setTitle((row[indexPath.row][1] as! String), for: .normal)
				cell.button.backgroundColor = AppValues.primaryColor
				cell.button.tintColor = AppValues.textColor
				cell.button.addTarget(self, action: #selector(RoutesTableViewController.rechercher(_:)), for: .touchUpInside)
                cell.backgroundColor = AppValues.primaryColor
				let view = UIView()
				view.backgroundColor = AppValues.primaryColor
				cell.selectedBackgroundView = view
				return cell
			}
		}
		else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "favorisCell", for: indexPath) as! FavoriteRouteTableViewCell
			cell.iconView.backgroundColor = AppValues.primaryColor
			
			let starIcon = FAKFontAwesome.starIcon(withSize: 20)!
			starIcon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.iconImageView.image = starIcon.image(with: CGSize(width: 20, height: 20))
			
			var icon = FAKIonIcons.logOutIcon(withSize: 21)!
			icon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			var attributedString = NSMutableAttributedString(attributedString: (icon.attributedString())!)
			attributedString.append(NSAttributedString(string: " " + (AppValues.favoritesRoutes![indexPath.row][0].fullName)))
			cell.departureLabel.attributedText = attributedString
			cell.departureLabel.textColor = AppValues.textColor
			cell.departureLabel.backgroundColor = AppValues.primaryColor
			
			let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 20)!
			iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.accessoryImage.image = iconCheveron.image(with: CGSize(width: 20, height: 20))
			
			icon = FAKIonIcons.logInIcon(withSize: 21)!
			icon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			attributedString = NSMutableAttributedString(attributedString: (icon.attributedString())!)
			attributedString.append(NSAttributedString(string: " " + (AppValues.favoritesRoutes![indexPath.row][1].fullName)))
			cell.arrivalLabel.attributedText = attributedString
			cell.arrivalLabel.textColor = AppValues.textColor
			cell.arrivalLabel.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.1)
			
			cell.selectionStyle = .none
			
			return cell
		}
	}
	
	func rechercher(_ sender: Any) {
		if ActualRoutes.route.departure != nil && ActualRoutes.route.arrival != nil && ActualRoutes.route.date != nil {

			performSegue(withIdentifier: "rechercherItineraire", sender: self)
		}
		else {
			let alert = SCLAlertView()
			alert.showWarning("Information manquante".localized(), subTitle: "Il manque une information pour rechercher un itinéraire".localized(), closeButtonTitle: "OK".localized(), duration: 10)
		}
	}
	
    func dateArriveeChange(_ sender: Any) {
        if (sender as! DGRunkeeperSwitch).selectedIndex == 0 {
            ActualRoutes.route.isArrivalDate = false
        }
        else if (sender as! DGRunkeeperSwitch).selectedIndex == 1 {
            ActualRoutes.route.isArrivalDate = true
        }
        else {
            print("The selected index of DGRunkeeperSwitch object is unknow")
        }
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (indexPath as NSIndexPath).section == 1 {
			ActualRoutes.route = SearchRoute(departure: AppValues.favoritesRoutes[(indexPath as NSIndexPath).row][0], arrival: AppValues.favoritesRoutes[(indexPath as NSIndexPath).row][1])
			performSegue(withIdentifier: "rechercherItineraire", sender: self)
		}
		else if (row[indexPath.row][0] as! String) == "itineraryCell" {
			performSegue(withIdentifier: row[indexPath.row][3] as! String, sender: self)
		}
		else {
			tableView.deselectRow(at: indexPath, animated: false)
		}
	}
		
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let returnedView = UIView()
		returnedView.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.1)
		
		let label = UILabel(frame: CGRect(x: 20, y: 5, width: 500, height: 30))
		label.text = headers[section]
		label.textColor = AppValues.textColor
		returnedView.addSubview(label)
		
		return returnedView
	}
	
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "voirArretsItineraire" {
			let destinationViewController = segue.destination as! RoutesStopsTableViewController
			if (tableView.cellForRow(at: tableView.indexPathForSelectedRow!)?.textLabel?.text == "Départ".localized() ) {
				destinationViewController.departure = true
			}
			else {
				destinationViewController.departure = false
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (indexPath as NSIndexPath).section == 0 {
			return 44
		}
		else {
			return 88
		}
	}
	
}

extension RoutesTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}
