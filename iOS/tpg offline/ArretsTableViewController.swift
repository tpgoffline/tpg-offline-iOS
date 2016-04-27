
//
//  ArretsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import PermissionScope
import DGElasticPullToRefresh
import INTULocationManager
import Localize_Swift

class ArretsTableViewController: UITableViewController, UISplitViewControllerDelegate {
    var arretsLocalisation = [Arret]()
    var filtredResults = [Arret]()
    let searchController = UISearchController(searchResultsController: nil)
    let defaults = NSUserDefaults.standardUserDefaults()
    var arretsKeys: [String] = []
    let pscope = PermissionScope()
    var chargementLocalisation = false
    
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
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized()
        searchController.searchBar.scopeButtonTitles = ["Arrets", "Lignes"]
        searchController.searchBar.delegate = self
        
        arretsKeys = [String](AppValues.arrets.keys)
        arretsKeys.sortInPlace({ (string1, string2) -> Bool in
            let stringA = String((AppValues.arrets[string1]?.titre)! + (AppValues.arrets[string1]?.sousTitre)!)
            let stringB = String((AppValues.arrets[string2]?.titre)! + (AppValues.arrets[string2]?.sousTitre)!)
            if stringA.lowercaseString < stringB.lowercaseString {
                return true
            }
            return false
        })
        
        actualiserTheme()
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
        chargementLocalisation = true
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
                self.arretsLocalisation = []
                AppValues.logger.info("Résultat de la localisation")
                
                if self.defaults.integerForKey("proximityDistance") == 0 {
                    self.defaults.setInteger(500, forKey: "proximityDistance")
                }
                
                for x in [Arret](AppValues.arrets.values) {
                    x.distance = location.distanceFromLocation(x.location)
                    
                    if (location.distanceFromLocation(x.location) <= Double(self.defaults.integerForKey("proximityDistance"))) {
                        
                        self.arretsLocalisation.append(x)
                        AppValues.logger.info(x.stopCode)
                        AppValues.logger.info(String(location.distanceFromLocation(x.location)))
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
                self.chargementLocalisation = false
                self.tableView.reloadData()
            }
            else {
                self.chargementLocalisation = false
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        actualiserTheme()
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
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
                if chargementLocalisation {
                    return 1
                }
                else {
                    return arretsLocalisation.count
                }
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
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !searchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            if indexPath.section == 0 {
                if chargementLocalisation {
                    let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.imageView?.image = iconLocation.imageWithSize(CGSize(width: 20, height: 20))
                    cell.textLabel?.text = "Recherche des arrets..."
                    cell.detailTextLabel?.text = ""
                    cell.accessoryView = UIView()
                }
                else {
                    let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
                    cell.textLabel?.text = arretsLocalisation[indexPath.row].nomComplet
                    cell.detailTextLabel!.text = "~" + String(Int(arretsLocalisation[indexPath.row].distance!)) + "m"
                    cell.imageView?.image = nil
                }
            }
            else if indexPath.section == 1 {
                let iconFavoris = FAKFontAwesome.starIconWithSize(20)
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconFavoris.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.titre
                cell.detailTextLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.sousTitre
                cell.imageView?.image = nil
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arrets[arretsKeys[indexPath.row]]!.titre
                cell.detailTextLabel!.text = AppValues.arrets[arretsKeys[indexPath.row]]!.sousTitre
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
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(20)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[indexPath.row].titre
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel!.text = filtredResults[indexPath.row].sousTitre
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            cell.imageView?.image = nil
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "afficherProchainsDeparts") {
            let nav = segue.destinationViewController as! UINavigationController
            let departsArretsViewController = nav.viewControllers[0] as! DepartsArretTableViewController
            if searchController.active {
                departsArretsViewController.arret = filtredResults[(tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                if tableView.indexPathForSelectedRow!.section == 0 {
                    departsArretsViewController.arret = arretsLocalisation[tableView.indexPathForSelectedRow!.row]
                }
                else if tableView.indexPathForSelectedRow!.section == 1 {
                    departsArretsViewController.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[tableView.indexPathForSelectedRow!.row]]
                }
                else {
                    departsArretsViewController.arret = AppValues.arrets[self.arretsKeys[(tableView.indexPathForSelectedRow?.row)!]]
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if tableView.indexPathForSelectedRow!.section == 0 && chargementLocalisation && !searchController.active {
            return false
        }
        else {
            return true
        }
    }
    deinit {
        tableView.dg_removePullToRefresh()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Arrets") {
        filtredResults = [Arret](AppValues.arrets.values).filter { arret in
            if scope == "Arrets" {
                return arret.nomComplet.lowercaseString.containsString(searchText.lowercaseString)
            }
            else if scope == "Lignes" {
                return arret.nomComplet.lowercaseString.containsString(searchText.lowercaseString)
            }
            else {
                return false
            }
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
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension ArretsTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension ArretsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension ArretsTableViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("departsArretTableViewController") as? DepartsArretTableViewController else { return nil }
        
        if searchController.active {
            detailVC.arret = filtredResults[indexPath.row]
        }
        else {
            if indexPath.section == 0 {
                detailVC.arret = arretsLocalisation[indexPath.row]
            }
            else if indexPath.section == 1 {
                detailVC.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]
            }
            else {
                detailVC.arret = AppValues.arrets[self.arretsKeys[indexPath.row]]
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