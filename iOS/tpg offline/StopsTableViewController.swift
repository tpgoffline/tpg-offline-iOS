
//
//  StopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import PermissionScope
import DGElasticPullToRefresh
import INTULocationManager
import Localize_Swift

class StopsTableViewController: UITableViewController, UISplitViewControllerDelegate {
    var localizedStops = [Stop]()
    var filtredResults = [Stop]()
    let searchController = UISearchController(searchResultsController: nil)
    let defaults = NSUserDefaults.standardUserDefaults()
    let pscope = PermissionScope()
    var localisationLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .AllVisible
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            self!.requestLocation()
            self?.tableView.dg_stopLoading()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darkenByPercentage(0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized()
        
        refreshTheme()
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        tableView.tableHeaderView = self.searchController.searchBar
        
        if #available(iOS 9.0, *) {
            if(traitCollection.forceTouchCapability == .Available){
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
        
        if !(NSProcessInfo.processInfo().arguments.contains("-donotask")) {
            
            switch PermissionScope().statusNotifications() {
            case .Unknown:
                // ask
                pscope.addPermission(NotificationsPermission(notificationCategories: nil), message: "Cette autorisation sert à envoyer des rappels.".localized())
            case .Unauthorized, .Disabled:
                // bummer
                return
            case .Authorized:
                // thanks!
                return
            }
            switch PermissionScope().statusLocationAlways() {
            case .Unknown:
                // ask
                pscope.addPermission(LocationAlwaysPermission(), message: "Cette autorisation sert à indiquer les arrets les plus proches.".localized())
            case .Unauthorized, .Disabled:
                // bummer
                return
            case .Authorized:
                requestLocation()
                return
            }
            
            pscope.headerLabel.text = "Bonjour".localized()
            pscope.bodyLabel.text = "Nous avons besoin de quelques autorisations".localized()
            pscope.closeButton.setTitle("X", forState: .Normal)
            pscope.show({ finished, results in
                AppValues.logger.info("got results \(results)")
                for x in results {
                    if x.type == PermissionType.LocationInUse {
                        self.requestLocation()
                    }
                }
                }, cancelled: { (results) -> Void in
                    AppValues.logger.info("thing was cancelled")
            })
            
        }
    }
    
    func requestLocation() {
        localisationLoading = true
        tableView.reloadData()
        var accurency = INTULocationAccuracy.Block
        if self.defaults.integerForKey("locationAccurency") == 1 {
            accurency = INTULocationAccuracy.House
        }
        else if self.defaults.integerForKey("locationAccurency") == 2 {
            accurency = INTULocationAccuracy.Room
        }
        
        let localisationManager = INTULocationManager.sharedInstance()
        localisationManager.requestLocationWithDesiredAccuracy(accurency, timeout: 60, delayUntilAuthorized: true) { (location, accurency, status) in
            if status == .Success {
                self.localizedStops = []
                AppValues.logger.info("Localisation results")
                
                if self.defaults.integerForKey("proximityDistance") == 0 {
                    self.defaults.setInteger(500, forKey: "proximityDistance")
                }
                
                for x in [Stop](AppValues.stops.values) {
                    x.distance = location.distanceFromLocation(x.location)
                    
                    if (location.distanceFromLocation(x.location) <= Double(self.defaults.integerForKey("proximityDistance"))) {
                        
                        self.localizedStops.append(x)
                        AppValues.logger.info(x.stopCode)
                        AppValues.logger.info(String(location.distanceFromLocation(x.location)))
                    }
                }
                self.localizedStops.sortInPlace({ (arret1, arret2) -> Bool in
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
            else {
                self.localisationLoading = false
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        
        refreshTheme()
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darkenByPercentage(0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        if !(NSProcessInfo.processInfo().arguments.contains("-donotask")) {
            switch PermissionScope().statusLocationAlways() {
            case .Unauthorized, .Disabled, .Unknown:
                // bummer
                return
            case .Authorized:
                requestLocation()
                return
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
                if localisationLoading {
                    return 1
                }
                else {
                    return localizedStops.count
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
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !searchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            if indexPath.section == 0 {
                if localisationLoading {
                    let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.imageView?.image = iconLocation.imageWithSize(CGSize(width: 20, height: 20))
                    cell.textLabel?.text = "Recherche des arrêts...".localized()
                    cell.detailTextLabel?.text = ""
                    cell.accessoryView = UIView()
                }
                else {
                    let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
                    cell.textLabel?.text = localizedStops[indexPath.row].fullName
                    cell.detailTextLabel!.text = "~" + String(Int(localizedStops[indexPath.row].distance!)) + "m"
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
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(20)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[indexPath.row].title
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel!.text = filtredResults[indexPath.row].subTitle
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            cell.imageView?.image = nil
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchController.searchBar.resignFirstResponder()
        if (segue.identifier == "afficherProchainsDeparts") {
            let nav = segue.destinationViewController as! UINavigationController
            let departsArretsViewController = nav.viewControllers[0] as! DeparturesTableViewController
            if searchController.active {
                departsArretsViewController.stop = filtredResults[(tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                if tableView.indexPathForSelectedRow!.section == 0 {
                    departsArretsViewController.stop = localizedStops[tableView.indexPathForSelectedRow!.row]
                }
                else if tableView.indexPathForSelectedRow!.section == 1 {
                    departsArretsViewController.stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[tableView.indexPathForSelectedRow!.row]]
                }
                else {
                    departsArretsViewController.stop = AppValues.stops[AppValues.stopsKeys[(tableView.indexPathForSelectedRow?.row)!]]
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if tableView.indexPathForSelectedRow!.section == 0 && localisationLoading && !searchController.active {
            return false
        }
        else {
            return true
        }
    }
    deinit {
        tableView.dg_removePullToRefresh()
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
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension StopsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension StopsTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
        
        if tableView.indexPathForSelectedRow!.section == 0 && localisationLoading && !searchController.active {
            return nil
        }
        
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("departsArretTableViewController") as? DeparturesTableViewController else { return nil }
        
        if searchController.active {
            detailVC.stop = filtredResults[indexPath.row]
        }
        else {
            if indexPath.section == 0 {
                detailVC.stop = localizedStops[indexPath.row]
            }
            else if indexPath.section == 1 {
                detailVC.stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]
            }
            else {
                detailVC.stop = AppValues.stops[AppValues.stopsKeys[indexPath.row]]
            }
        }
        if #available(iOS 9.0, *) {
            previewingContext.sourceRect = cell.frame
        }
        return detailVC
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        showViewController(viewControllerToCommit, sender: self)
        
    }
}