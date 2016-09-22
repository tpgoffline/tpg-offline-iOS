
//
//  StopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Chameleon
import PermissionScope
import INTULocationManager
import FontAwesomeKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class StopsTableViewController: UITableViewController, UISplitViewControllerDelegate {
    var localizedStops = [Stop]()
    var filtredResults = [Stop]()
    let searchController = UISearchController(searchResultsController: nil)
    let defaults = UserDefaults.standard
    let pscope = PermissionScope()
    var localisationLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            self!.requestLocation()
            self?.tableView.dg_stopLoading()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
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
        
            if(traitCollection.forceTouchCapability == .available){
                registerForPreviewing(with: self, sourceView: view)
            }
        
        if !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            switch PermissionScope().statusNotifications() {
            case .unknown:
                // ask
                pscope.addPermission(NotificationsPermission(notificationCategories: nil), message: "Cette autorisation sert à envoyer des rappels.".localized())
            case .unauthorized, .disabled:
                // bummer
                return
            case .authorized:
                // thanks!
                return
            }
            switch PermissionScope().statusLocationInUse() {
            case .unknown:
                // ask
                pscope.addPermission(LocationWhileInUsePermission(), message: "Cette autorisation sert à indiquer les arrets les plus proches.".localized())
            case .unauthorized, .disabled:
                // bummer
                return
            case .authorized:
                requestLocation()
                return
            }
            
            pscope.headerLabel.text = "Bonjour".localized()
            pscope.bodyLabel.text = "Nous avons besoin de quelques autorisations".localized()
            pscope.closeButton.setTitle("X", for: UIControlState())
            pscope.show({ finished, results in
                AppValues.logger.info("got results \(results)")
                for x in results {
                    if x.type == PermissionType.locationInUse {
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
        var accurency = INTULocationAccuracy.block
        if self.defaults.integer(forKey: "locationAccurency") == 1 {
            accurency = INTULocationAccuracy.house
        }
        else if self.defaults.integer(forKey: "locationAccurency") == 2 {
            accurency = INTULocationAccuracy.room
        }
        
        let localisationManager = INTULocationManager.sharedInstance()
        localisationManager.requestLocation(withDesiredAccuracy: accurency, timeout: 60, delayUntilAuthorized: true) { (location, accurency, status) in
            if status == .success {
                self.localizedStops = []
                AppValues.logger.info("Localisation results")
                
                if self.defaults.integer(forKey: "proximityDistance") == 0 {
                    self.defaults.set(500, forKey: "proximityDistance")
                }
                
                for x in [Stop](AppValues.stops.values) {
                    x.distance = location?.distance(from: x.location)
                    
                    if ((location?.distance(from: x.location))! <= Double(self.defaults.integer(forKey: "proximityDistance"))) {
                        
                        self.localizedStops.append(x)
                        AppValues.logger.info(x.stopCode)
                        AppValues.logger.info(String(describing: location?.distance(from: x.location)))
                    }
                }
                self.localizedStops.sort(by: { (arret1, arret2) -> Bool in
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        
        refreshTheme()
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        if !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            switch PermissionScope().statusLocationAlways() {
            case .unauthorized, .disabled, .unknown:
                // bummer
                return
            case .authorized:
                requestLocation()
                return
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !searchController.isActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            if (indexPath as NSIndexPath).section == 0 {
                if localisationLoading {
                    let iconLocation = FAKFontAwesome.locationArrowIcon(withSize: 20)!
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.imageView?.image = iconLocation.image(with: CGSize(width: 20, height: 20))
                    cell.textLabel?.text = "Recherche des arrêts...".localized()
                    cell.detailTextLabel?.text = ""
                    cell.accessoryView = UIView()
                }
                else {
                    let iconLocation = FAKFontAwesome.locationArrowIcon(withSize: 20)!
                    iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.accessoryView = UIImageView(image: iconLocation.image(with: CGSize(width: 20, height: 20)))
                    cell.textLabel?.text = localizedStops[(indexPath as NSIndexPath).row].fullName
                    cell.detailTextLabel!.text = "~" + String(Int(localizedStops[(indexPath as NSIndexPath).row].distance!)) + "m"
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
            let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 20)!
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[(indexPath as NSIndexPath).row].title
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel!.text = filtredResults[(indexPath as NSIndexPath).row].subTitle
            cell.accessoryView = UIImageView(image: iconCheveron.image(with: CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            cell.imageView?.image = nil
            
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchController.searchBar.resignFirstResponder()
        if (segue.identifier == "afficherProchainsDeparts") {
            let nav = segue.destination as! UINavigationController
            let departsArretsViewController = nav.viewControllers[0] as! DeparturesTableViewController
            if searchController.isActive {
                departsArretsViewController.stop = filtredResults[((tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
            }
            else {
                if (tableView.indexPathForSelectedRow! as IndexPath).section == 0 {
                    departsArretsViewController.stop = localizedStops[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
                }
                else if (tableView.indexPathForSelectedRow! as IndexPath).section == 1 {
                    departsArretsViewController.stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[(tableView.indexPathForSelectedRow! as NSIndexPath).row]]
                }
                else {
                    departsArretsViewController.stop = AppValues.stops[AppValues.stopsKeys[((tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]]
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (tableView.indexPathForSelectedRow! as IndexPath).section == 0 && localisationLoading && !searchController.isActive {
            return false
        }
        else {
            return true
        }
    }
    deinit {
        tableView.dg_removePullToRefresh()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let espacapedSearchTextString = searchText.lowercased().folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
        filtredResults = [Stop](AppValues.stops.values).filter { arret in
            return arret.fullName.lowercased().folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "").contains(espacapedSearchTextString)
        }
        filtredResults.sort(by: { (arret1, arret2) -> Bool in
            let stringA = String(arret1.title + arret1.subTitle).folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "").lowercased()
            let stringB = String(arret2.title + arret2.subTitle).folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "").lowercased()
            if stringA < stringB {
                return true
            }
            return false
        })
        
        tableView.reloadData()
    }
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension StopsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension StopsTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        if (tableView.indexPathForSelectedRow! as IndexPath).section == 0 && localisationLoading && !searchController.isActive {
            return nil
        }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "departsArretTableViewController") as? DeparturesTableViewController else { return nil }
        
        if searchController.isActive {
            detailVC.stop = filtredResults[(indexPath as NSIndexPath).row]
        }
        else {
            if (indexPath as NSIndexPath).section == 0 {
                detailVC.stop = localizedStops[(indexPath as NSIndexPath).row]
            }
            else if (indexPath as NSIndexPath).section == 1 {
                detailVC.stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[(indexPath as NSIndexPath).row]]
            }
            else {
                detailVC.stop = AppValues.stops[AppValues.stopsKeys[(indexPath as NSIndexPath).row]]
            }
        }
            previewingContext.sourceRect = cell.frame
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
}
