//
//  RoutesStopsTableViewController.swift
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

class RoutesStopsTableViewController: UITableViewController {
    var departure: Bool!
    var localisationStops = [Stop]()
    var filtredResults = [Stop]()
    let searchController = UISearchController(searchResultsController: nil)
    var locationManager = CLLocationManager()
    let defaults = NSUserDefaults.standardUserDefaults()
    var localisationLoading: Bool = false
    
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
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized()
        
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
        
        
        refreshTheme()
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
                if (localisationLoading == true) {
                    return 1
                }
                else {
                    return localisationStops.count
                }
            }
            else if section == 1 {
                if (AppValues.favoritesStops == nil) {
                    return 0
                }
                else {
                    return AppValues.favoritesStops.count
                }
            }
            else {
                return AppValues.stops.count
            }
        }
    }
    
    func requestLocation() {
        localisationLoading = true
        tableView.reloadData()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !searchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            if indexPath.section == 0 {
                if localisationLoading {
                    let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.imageView?.image = iconLocation.imageWithSize(CGSize(width: 20, height: 20))
                    cell.textLabel?.text = "Recherche des arrêts..."
                    cell.detailTextLabel?.text = ""
                    cell.accessoryView = UIView()
                }
                else {
                    let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
                    cell.textLabel?.text = localisationStops[indexPath.row].fullName
                    cell.detailTextLabel!.text = "~" + String(Int(localisationStops[indexPath.row].distance!)) + "m"
                    cell.imageView?.image = nil
                }
            }
            else if indexPath.section == 1 {
                let iconFavoris = FAKFontAwesome.starIconWithSize(20)
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconFavoris.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]?.title
                cell.detailTextLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]?.subTitle
                cell.imageView?.image = nil
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.stops[AppValues.stopsKeys[indexPath.row]]!.title
                cell.detailTextLabel!.text = AppValues.stops[AppValues.stopsKeys[indexPath.row]]!.subTitle
                cell.imageView?.image = nil
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
            cell.textLabel?.text = filtredResults[indexPath.row].title
            cell.detailTextLabel!.text = filtredResults[indexPath.row].subTitle
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var arret: Stop? = nil
        if searchController.active {
            arret = filtredResults[indexPath.row]
        }
        else {
            if indexPath.section == 0 {
                if !localisationLoading {
                    arret = localisationStops[indexPath.row]
                }
            }
            else if indexPath.section == 1 {
                arret = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]
            }
            else {
                arret = AppValues.stops[AppValues.stopsKeys[indexPath.row]]!
            }
        }
        if arret != nil {
            if (departure == true) {
                ActualRoutes.route.departure = arret!
            }
            else {
                ActualRoutes.route.arrival = arret!
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        filtredResults = [Stop](AppValues.stops.values).filter { arret in
            return arret.fullName.lowercaseString.containsString(searchText.lowercaseString)
        }
        filtredResults.sortInPlace { (arret1, arret2) -> Bool in
            let stringA = String(arret1.title + arret1.subTitle)
            let stringB = String(arret2.title + arret2.subTitle)
            if stringA.lowercaseString < stringB.lowercaseString {
                return true
            }
            return false
        }
        
        tableView.reloadData()
    }
}

extension RoutesStopsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension RoutesStopsTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = locations[0]
        self.localisationStops = []
        AppValues.logger.info("Résultat de la localisation")
        
        if self.defaults.integerForKey("proximityDistance") == 0 {
            self.defaults.setInteger(500, forKey: "proximityDistance")
        }
        
        for x in [Stop](AppValues.stops.values) {
            x.distance = location.distanceFromLocation(x.location)
            
            if (location.distanceFromLocation(x.location) <= Double(self.defaults.integerForKey("proximityDistance"))) {
                
                self.localisationStops.append(x)
                AppValues.logger.info(x.stopCode)
                AppValues.logger.info(String(location.distanceFromLocation(x.location)))
            }
        }
        self.localisationStops.sortInPlace({ (arret1, arret2) -> Bool in
            if arret1.distance < arret2.distance {
                return true
            }
            else {
                return false
            }
        })
        self.localisationLoading = false
        self.tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.localisationLoading = false
        self.tableView.reloadData()
        AppValues.logger.warning("Error while updating location " + error.localizedDescription)
    }
}