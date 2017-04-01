//
//  RoutesStopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import SwiftLocation

class RoutesStopsTableViewController: UITableViewController {
    var departure: Bool!
    var localizedStops = [Stop]()
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

        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(percentage: 0.1)!)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.backgroundColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor

        navigationController?.navigationBar.barTintColor = AppValues.primaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        tableView.backgroundColor = AppValues.primaryColor
        tableView.tableHeaderView = self.searchController.searchBar

        requestLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(percentage: 0.1)!)
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

    func refresh(_ sender:Any) {
        requestLocation()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        } else {
            return [String](AppValues.stopsABC.keys).count + 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive {
            return self.filtredResults.count
        } else {
            if section == 0 {
                if localisationLoading {
                    return 1
                } else {
                    return localizedStops.count
                }
            } else if section == 1 {
                if AppValues.favoritesStops == nil {
                    return 0
                } else {
                    return AppValues.favoritesStops.count
                }
            } else {
                return (AppValues.stopsABC[[String](AppValues.stopsABC.keys).sorted()[section - 2]]?.count)!
            }
        }
    }

    func requestLocation() {
        localisationLoading = true
        self.localizedStops = []
        tableView.reloadData()

        var accuracy = Accuracy.block
        if self.defaults.integer(forKey: "locationAccurency") == 1 {
            accuracy = .house
        } else if self.defaults.integer(forKey: "locationAccurency") == 2 {
            accuracy = .room
        }

        Location.getLocation(accuracy: accuracy, frequency: .oneShot, success: { (_, location) -> (Void) in
            print("Localisation results: \(location)")

            if self.defaults.integer(forKey: UserDefaultsKeys.proximityDistance.rawValue) == 0 {
                self.defaults.set(500, forKey: UserDefaultsKeys.proximityDistance.rawValue)
            }

            self.localizedStops = []

            for x in [Stop](AppValues.stops.values) {
                x.distance = location.distance(from: x.location)

                if (location.distance(from: x.location)) <= Double(self.defaults.integer(forKey: "proximityDistance")) {

                    self.localizedStops.append(x)
                    print(x.stopCode)
                    print(String(describing: location.distance(from: x.location)))
                }
            }
            self.localizedStops.sort(by: { (arret1, arret2) -> Bool in
                if arret1.distance! < arret2.distance! {
                    return true
                } else {
                    return false
                }
            })
            self.localizedStops = Array(self.localizedStops.prefix(5))
            self.localisationLoading = false
            self.tableView.reloadData()
        }) { (_, location, error) -> (Void) in
            print("Location update failed: \(error.localizedDescription)")
            print("Last location: \(String(describing: location))")
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
                    cell.imageView?.image = #imageLiteral(resourceName: "location").maskWithColor(color: AppValues.textColor)
                    cell.textLabel?.text = "Recherche des arrêts..."
                    cell.detailTextLabel?.text = ""
                    cell.accessoryView = UIView()
                } else {
                    cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "location").maskWithColor(color: AppValues.textColor))
                    cell.textLabel?.text = localizedStops[indexPath.row].fullName
                    cell.detailTextLabel!.text = "~" + String(Int(localizedStops[indexPath.row].distance!)) + "m"
                    cell.imageView?.image = nil
                }
            } else if indexPath.section == 1 {
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "starNavbar").maskWithColor(color: AppValues.textColor))
                cell.textLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]?.title
                cell.detailTextLabel?.text = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]?.subTitle
                cell.imageView?.image = nil
            } else {
                let image: UIImage
                let stop = AppValues.stops[AppValues.stopsKeys[indexPath.row]]!
                if departure == true {
                    if ActualRoutes.route.departure?.stopCode != stop.stopCode {
                        image = #imageLiteral(resourceName: "circleEmpty")
                    } else {
                        image = #imageLiteral(resourceName: "circle")
                    }
                } else {
                    if ActualRoutes.route.arrival?.stopCode != stop.stopCode {
                        image = #imageLiteral(resourceName: "circleEmpty")
                    } else {
                        image = #imageLiteral(resourceName: "circle")
                    }
                }
                let letterContent = AppValues.stopsABC[[String](AppValues.stopsABC.keys).sorted()[indexPath.section - 2]] ?? ["Error"]
                cell.accessoryView = UIImageView(image: image.maskWithColor(color: AppValues.textColor))
                cell.textLabel?.text = AppValues.stops[letterContent[indexPath.row]]!.title
                cell.detailTextLabel!.text = AppValues.stops[letterContent[indexPath.row]]!.subTitle
                cell.imageView?.image = nil
            }

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            let image: UIImage
            let stop = filtredResults[indexPath.row]

            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = stop.title
            cell.detailTextLabel!.text = stop.subTitle
            cell.backgroundColor = AppValues.primaryColor

            if departure == true {
                if ActualRoutes.route.departure?.stopCode != stop.stopCode {
                    image = #imageLiteral(resourceName: "circleEmpty")
                } else {
                    image = #imageLiteral(resourceName: "circle")
                }
            } else {
                if ActualRoutes.route.arrival?.stopCode != stop.stopCode {
                    image = #imageLiteral(resourceName: "circleEmpty")
                } else {
                    image = #imageLiteral(resourceName: "circle")
                }
            }
            cell.accessoryView = UIImageView(image: image.maskWithColor(color: AppValues.textColor))

            return cell
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var stop: Stop? = nil
        if searchController.isActive {
            stop = filtredResults[indexPath.row]
        } else {
            if indexPath.section == 0 {
                if !localisationLoading {
                    stop = localizedStops[indexPath.row]
                }
            } else if indexPath.section == 1 {
                stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]
            } else {
                let letterContent = AppValues.stopsABC[[String](AppValues.stopsABC.keys).sorted()[indexPath.section - 2]] ?? ["Error"]
                stop = AppValues.stops[letterContent[indexPath.row]]!
            }
        }
        if stop != nil {
            if departure == true {
                ActualRoutes.route.departure = stop!
            } else {
                ActualRoutes.route.arrival = stop!
            }
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 2
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive {
            return []
        }
        return [String](AppValues.stopsABC.keys).sorted()
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
