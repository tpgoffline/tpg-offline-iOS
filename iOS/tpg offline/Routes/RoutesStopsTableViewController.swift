//
//  RoutesStopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Chameleon
import CoreLocation
import FontAwesomeKit

class RoutesStopsTableViewController: UITableViewController {
    var departure: Bool!
    var localisationStops = [Stop]()
    var filtredResults = [Stop]()
    let searchController = UISearchController(searchResultsController: nil)
    var locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    var localisationLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            self!.refresh(loadingView)
            self?.tableView.dg_stopLoading()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized()
        
        navigationController?.navigationBar.barTintColor = AppValues.primaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        tableView.backgroundColor = AppValues.primaryColor
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        tableView.tableHeaderView = self.searchController.searchBar
        
        
        locationManager.delegate = self
        var accurency = kCLLocationAccuracyHundredMeters
        if self.defaults.integer(forKey: "locationAccurency") == 1 {
            accurency = kCLLocationAccuracyNearestTenMeters
        }
        else if self.defaults.integer(forKey: "locationAccurency") == 2 {
            accurency = kCLLocationAccuracyBest
        }
        locationManager.desiredAccuracy = accurency
        
        requestLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
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
    
    func refresh(_ sender:Any)
    {
        requestLocation()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive {
            return 1
        }
        else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !searchController.isActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            if (indexPath as NSIndexPath).section == 0 {
                if localisationLoading {
                    let iconLocation = FAKFontAwesome.locationArrowIcon(withSize: 20)!
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.imageView?.image = iconLocation.image(with: CGSize(width: 20, height: 20))
                    cell.textLabel?.text = "Recherche des arrêts..."
                    cell.detailTextLabel?.text = ""
                    cell.accessoryView = UIView()
                }
                else {
                    let iconLocation = FAKFontAwesome.locationArrowIcon(withSize: 20)!
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.accessoryView = UIImageView(image: iconLocation.image(with: CGSize(width: 20, height: 20)))
                    cell.textLabel?.text = localisationStops[(indexPath as NSIndexPath).row].fullName
                    cell.detailTextLabel!.text = "~" + String(Int(localisationStops[(indexPath as NSIndexPath).row].distance!)) + "m"
                    cell.imageView?.image = nil
                }
            }
            else if (indexPath as NSIndexPath).section == 1 {
                let iconFavoris = FAKFontAwesome.starIcon(withSize: 20)!
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconFavoris.image(with: CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[(indexPath as NSIndexPath).row]]?.title
                cell.detailTextLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[(indexPath as NSIndexPath).row]]?.subTitle
                cell.imageView?.image = nil
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 15)!
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconCheveron.image(with: CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.stops[AppValues.stopsKeys[(indexPath as NSIndexPath).row]]!.title
                cell.detailTextLabel!.text = AppValues.stops[AppValues.stopsKeys[(indexPath as NSIndexPath).row]]!.subTitle
                cell.imageView?.image = nil
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 15)!
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[(indexPath as NSIndexPath).row].title
            cell.detailTextLabel!.text = filtredResults[(indexPath as NSIndexPath).row].subTitle
            cell.accessoryView = UIImageView(image: iconCheveron.image(with: CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var arret: Stop? = nil
        if searchController.isActive {
            arret = filtredResults[(indexPath as NSIndexPath).row]
        }
        else {
            if (indexPath as NSIndexPath).section == 0 {
                if !localisationLoading {
                    arret = localisationStops[(indexPath as NSIndexPath).row]
                }
            }
            else if (indexPath as NSIndexPath).section == 1 {
                arret = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[(indexPath as NSIndexPath).row]]
            }
            else {
                arret = AppValues.stops[AppValues.stopsKeys[(indexPath as NSIndexPath).row]]!
            }
        }
        if arret != nil {
            if (departure == true) {
                ActualRoutes.route.departure = arret!
            }
            else {
                ActualRoutes.route.arrival = arret!
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let espacapedSearchTextString = searchText.lowercased().folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
        filtredResults = [Stop](AppValues.stops.values).filter { arret in
            return arret.fullName.lowercased().folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "").contains(espacapedSearchTextString)
        }
        filtredResults.sort(by: { (arret1, arret2) -> Bool in
            let stringA = String(arret1.title + arret1.subTitle).lowercased().folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
            let stringB = String(arret2.title + arret2.subTitle).lowercased().folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
            if stringA < stringB {
                return true
            }
            return false
        })
        
        tableView.reloadData()
    }
}

extension RoutesStopsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension RoutesStopsTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = locations[0]
        self.localisationStops = []
        AppValues.logger.info("Résultat de la localisation")
        
        if self.defaults.integer(forKey: "proximityDistance") == 0 {
            self.defaults.set(500, forKey: "proximityDistance")
        }
        
        for x in [Stop](AppValues.stops.values) {
            x.distance = location.distance(from: x.location)
            
            if (location.distance(from: x.location) <= Double(self.defaults.integer(forKey: "proximityDistance"))) {
                
                self.localisationStops.append(x)
                AppValues.logger.info(x.stopCode)
                AppValues.logger.info(String(location.distance(from: x.location)))
            }
        }
        self.localisationStops.sort(by: { (arret1, arret2) -> Bool in
            if arret1.distance! < arret2.distance! {
                return true
            }
            else {
                return false
            }
        })
        self.localisationLoading = false
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.localisationLoading = false
        self.tableView.reloadData()
        AppValues.logger.warning("Error while updating location " + error.localizedDescription)
    }
}
