//
//  tpgArretSelectionTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import CoreLocation
import DGElasticPullToRefresh

class tpgArretSelectionTableViewController: UITableViewController {
    var depart: Bool!
    var arretsLocalisation = [Arret]()
    var filtredResults = [Arret]()
    let searchController = UISearchController(searchResultsController: nil)
    var locationManager = CLLocationManager()
    let tpgUrl = tpgURL()
    let defaults = NSUserDefaults.standardUserDefaults()
    var arretsKeys: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let loadingView = DGElasticPullToRefreshLoadingViewCircle()
		loadingView.tintColor = AppValues.textColor
		
		tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
			
			self!.refresh(loadingView)
			self?.tableView.dg_stopLoading()
			
			}, loadingView: loadingView)
		
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrets".localized()
        
        arretsKeys = [String](AppValues.arrets.keys)
        arretsKeys.sortInPlace({ (string1, string2) -> Bool in
			let stringA = String((AppValues.arrets[string1]?.titre)! + (AppValues.arrets[string1]?.sousTitre)!)
			let stringB = String((AppValues.arrets[string2]?.titre)! + (AppValues.arrets[string2]?.sousTitre)!)
			if stringA.lowercaseString < stringB.lowercaseString {
				return true
			}
			return false
        })
		
		navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
		navigationController?.navigationBar.tintColor = AppValues.textColor
		tableView.backgroundColor = AppValues.primaryColor
		searchController.searchBar.barTintColor = AppValues.primaryColor
		searchController.searchBar.tintColor = AppValues.textColor
		tableView.tableHeaderView = self.searchController.searchBar
		
		
		locationManager.delegate = self
		var accurency = kCLLocationAccuracyHundredMeters
		if self.defaults.integerForKey("locationAccurency") == 1 {
			accurency = kCLLocationAccuracyNearestTenMeters
		}
		else if self.defaults.integerForKey("locationAccurency") == 2 {
			accurency = kCLLocationAccuracyBest
		}
		locationManager.desiredAccuracy = accurency
		
		requestLocation()
    }
	
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
     
        actualiserTheme()
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
    }
	
	deinit {
		tableView.dg_removePullToRefresh()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh(sender:AnyObject)
    {
        requestLocation()
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if searchController.active {
            return 1
        }
        else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            return self.filtredResults.count
        }
        else {
            if section == 0 {
                return arretsLocalisation.count
            }
            else if section == 1 {
                if (AppValues.arretsFavoris == nil) {
                    return 0
                }
                else {
                    return AppValues.arretsFavoris.count
                }
            }
            else {
                return AppValues.arrets.count
            }
        }
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !searchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            if indexPath.section == 0 {
                let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = arretsLocalisation[indexPath.row].nomComplet
                cell.detailTextLabel!.text = "~" + String(Int(arretsLocalisation[indexPath.row].distance!)) + "m"
            }
            else if indexPath.section == 1 {
                let iconFavoris = FAKFontAwesome.starIconWithSize(20)
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconFavoris.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.titre
                cell.detailTextLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.sousTitre
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arrets[arretsKeys[indexPath.row]]!.titre
                cell.detailTextLabel!.text = AppValues.arrets[arretsKeys[indexPath.row]]!.sousTitre
            }
            
            let backgroundView = UIView()
			backgroundView.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = backgroundView
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			
			let backgroundView = UIView()
			backgroundView.backgroundColor = AppValues.secondaryColor
			cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[indexPath.row].titre
            cell.detailTextLabel!.text = filtredResults[indexPath.row].sousTitre
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var arret: Arret!
        if searchController.active {
            arret = filtredResults[indexPath.row]
        }
        else {
            if indexPath.section == 0 {
                arret = arretsLocalisation[indexPath.row]
            }
            else if indexPath.section == 1 {
                arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]
            }
            else {
                arret = AppValues.arrets[arretsKeys[indexPath.row]]!
            }
        }
        if (depart == true) {
            ItineraireEnCours.itineraire.depart = arret
        }
        else {
            ItineraireEnCours.itineraire.arrivee = arret
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func filterContentForSearchText(searchText: String) {
        filtredResults = [Arret](AppValues.arrets.values).filter { arret in
            return arret.nomComplet.lowercaseString.containsString(searchText.lowercaseString)
        }
        filtredResults.sortInPlace { (arret1, arret2) -> Bool in
			let stringA = String(arret1.titre + arret1.sousTitre)
			let stringB = String(arret2.titre + arret2.sousTitre)
			if stringA.lowercaseString < stringB.lowercaseString {
				return true
			}
			return false
        }
        
        tableView.reloadData()
    }
}

extension tpgArretSelectionTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension tpgArretSelectionTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = locations[0]
        self.arretsLocalisation = []
        print("Résultat de la localisation")
        
        if self.defaults.integerForKey("proximityDistance") == 0 {
            self.defaults.setInteger(500, forKey: "proximityDistance")
        }
        
        for x in [Arret](AppValues.arrets.values) {
            x.distance = location.distanceFromLocation(x.location)
            
            if (location.distanceFromLocation(x.location) <= Double(self.defaults.integerForKey("proximityDistance"))) {
                
                self.arretsLocalisation.append(x)
                print(x.stopCode)
                print(String(location.distanceFromLocation(x.location)))
            }
        }
        self.arretsLocalisation.sortInPlace({ (arret1, arret2) -> Bool in
            if arret1.distance < arret2.distance {
                return true
            }
            else {
                return false
            }
        })
        self.tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
}