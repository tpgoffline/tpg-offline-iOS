//
//  RoutesStopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Chameleon
import FontAwesomeKit

class RoutesStopsTableViewController: UITableViewController {
    var departure: Bool!
    var localisationStops = [Stop]()
    var filtredResults = [Stop]()
    let searchController = UISearchController(searchResultsController: nil)
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
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1)!)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized
        
        navigationController?.navigationBar.barTintColor = AppValues.primaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        tableView.backgroundColor = AppValues.primaryColor
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        tableView.tableHeaderView = self.searchController.searchBar
        
        requestLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1)!)
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
        self.localisationStops = []
        tableView.reloadData()
        
        var accuracy = Accuracy.block
        if self.defaults.integer(forKey: "locationAccurency") == 1 {
            accuracy = .house
        }
        else if self.defaults.integer(forKey: "locationAccurency") == 2 {
            accuracy = .room
        }
        
        Location.getLocation(withAccuracy: accuracy, frequency: .oneShot, timeout: 60, onSuccess: { (location) in
            print("Localisation results: \(location)")
            
            if self.defaults.integer(forKey: UserDefaultsKeys.proximityDistance.rawValue) == 0 {
                self.defaults.set(500, forKey: UserDefaultsKeys.proximityDistance.rawValue)
            }
            
            for x in [Stop](AppValues.stops.values) {
                x.distance = location.distance(from: x.location)
                
                if ((location.distance(from: x.location)) <= Double(self.defaults.integer(forKey: "proximityDistance"))) {
                    
                    self.localisationStops.append(x)
                    print(x.stopCode)
                    print(String(describing: location.distance(from: x.location)))
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
        }) { (location, error) in
            print("Location update failed: \(error.localizedDescription)")
            print("Last location: \(location)")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !searchController.isActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor
            
            if indexPath.section == 0 {
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
                    cell.textLabel?.text = localisationStops[indexPath.row].fullName
                    cell.detailTextLabel!.text = "~" + String(Int(localisationStops[indexPath.row].distance!)) + "m"
                    cell.imageView?.image = nil
                }
            }
            else if indexPath.section == 1 {
                let iconFavoris = FAKFontAwesome.starIcon(withSize: 20)!
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconFavoris.image(with: CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]?.title
                cell.detailTextLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]?.subTitle
                cell.imageView?.image = nil
            }
            else {
                let iconCircle: FAKFontAwesome
                let stop = AppValues.stops[AppValues.stopsKeys[indexPath.row]]!
                if (departure == true) {
                    if ActualRoutes.route.departure?.stopCode != stop.stopCode {
                        iconCircle = FAKFontAwesome.circleOIcon(withSize: 20)
                    } else {
                        iconCircle = FAKFontAwesome.checkCircleOIcon(withSize: 20)
                    }
                }
                else {
                    if ActualRoutes.route.arrival?.stopCode != stop.stopCode {
                        iconCircle = FAKFontAwesome.circleOIcon(withSize: 20)
                    } else {
                        iconCircle = FAKFontAwesome.checkCircleOIcon(withSize: 20)
                    }
                }
                iconCircle.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconCircle.image(with: CGSize(width: 20, height: 20)))
                cell.textLabel?.text = stop.title
                cell.detailTextLabel!.text = stop.subTitle
                cell.imageView?.image = nil
            }
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            let iconCircle: FAKFontAwesome
            let stop = filtredResults[indexPath.row]
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = stop.title
            cell.detailTextLabel!.text = stop.subTitle
            cell.backgroundColor = AppValues.primaryColor
            
            if (departure == true) {
                if ActualRoutes.route.departure?.stopCode != stop.stopCode {
                    iconCircle = FAKFontAwesome.circleOIcon(withSize: 20)
                } else {
                    iconCircle = FAKFontAwesome.checkCircleOIcon(withSize: 20)
                }
            }
            else {
                if ActualRoutes.route.arrival?.stopCode != stop.stopCode {
                    iconCircle = FAKFontAwesome.circleOIcon(withSize: 20)
                } else {
                    iconCircle = FAKFontAwesome.checkCircleOIcon(withSize: 20)
                }
            }
            iconCircle.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.accessoryView = UIImageView(image: iconCircle.image(with: CGSize(width: 20, height: 20)))
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var arret: Stop? = nil
        if searchController.isActive {
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
