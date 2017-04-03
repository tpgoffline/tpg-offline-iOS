//
//  StopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseCrash
import StoreKit
import DGElasticPullToRefresh
import SwiftLocation

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
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
    var localizedStops: [Stop] = []
    var filtredResults: [Stop] = []
    let searchController = UISearchController(searchResultsController: nil)
    let defaults = UserDefaults.standard
    var localisationLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAnalytics.logEvent(withName: "stopsViewController", parameters: [:])

        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.primaryColor

        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in

            self!.requestLocation()
            self?.tableView.dg_stopLoading()

            }, loadingView: loadingView)

        tableView.dg_setPullToRefreshFillColor(AppValues.textColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized

        refreshTheme()
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        tableView.tableHeaderView = self.searchController.searchBar

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        requestLocation()

        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
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

                if (location.distance(from: x.location)) <= Double(self.defaults.integer(forKey: UserDefaultsKeys.proximityDistance.rawValue)) {

                    self.localizedStops.append(x)
                    print(x.stopCode)
                    print(String(describing: location.distance(from: x.location)))
                }
            }
            self.localizedStops.sort(by: { (arret1, arret2) -> Bool in
                if arret1.distance < arret2.distance {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor

        refreshTheme()

        tableView.dg_setPullToRefreshFillColor(AppValues.textColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        requestLocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !searchController.isActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            if indexPath.section == 0 {
                if localisationLoading {
                    cell.imageView?.image = #imageLiteral(resourceName: "location").maskWithColor(color: AppValues.textColor)
                    cell.textLabel?.text = "Recherche des arrêts...".localized
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
                let letterContent = AppValues.stopsABC[[String](AppValues.stopsABC.keys).sorted()[indexPath.section - 2]] ?? ["Error"]
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWithColor(color: AppValues.textColor))
                cell.textLabel?.text = AppValues.stops[letterContent[indexPath.row]]!.title
                cell.detailTextLabel!.text = AppValues.stops[letterContent[indexPath.row]]!.subTitle
                cell.imageView?.image = nil
            }

            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arretsCell", for: indexPath)
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWithColor(color: AppValues.textColor))

            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[indexPath.row].title
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel!.text = filtredResults[indexPath.row].subTitle
            cell.backgroundColor = AppValues.primaryColor
            cell.imageView?.image = nil

            return cell
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchController.searchBar.resignFirstResponder()
        if segue.identifier == "afficherProchainsDeparts" {
            guard let nav = segue.destination as? UINavigationController else {
                FIRCrashMessage("*** WARNING ***: \(#file):\(#line): Guard failed")
                return
            }
            if let departuresViewController = nav.viewControllers[0] as? DeparturesViewController {
                if searchController.isActive {
                    departuresViewController.stop = filtredResults[(tableView.indexPathForSelectedRow?.row)!]
                } else {
                    let indexPath = tableView.indexPathForSelectedRow! as IndexPath
                    if indexPath.section == 0 {
                        departuresViewController.stop = localizedStops[indexPath.row]
                    } else if indexPath.section == 1 {
                        departuresViewController.stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]
                    } else {
                        let letterContent = AppValues.stopsABC[[String](AppValues.stopsABC.keys).sorted()[indexPath.section - 2]] ?? ["Error"]
                        departuresViewController.stop = AppValues.stops[letterContent[indexPath.row]]!
                    }
                }
                FIRCrashMessage("Request \(String(describing: departuresViewController.stop))")
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (tableView.indexPathForSelectedRow! as IndexPath).section == 0 && localisationLoading && !searchController.isActive {
            return false
        } else {
            return true
        }
    }

    deinit {
        if let table = tableView {
            table.dg_removePullToRefresh()
        }
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

        if indexPath.section == 0 && localisationLoading && !searchController.isActive {
            return nil
        }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "departuresViewController") as? DeparturesViewController else { return nil }

        if searchController.isActive {
            detailVC.stop = filtredResults[indexPath.row]
        } else {
            if indexPath.section == 0 {
                detailVC.stop = localizedStops[indexPath.row]
            } else if indexPath.section == 1 {
                detailVC.stop = AppValues.favoritesStops[AppValues.fullNameFavoritesStops[indexPath.row]]
            } else {
                detailVC.stop = AppValues.stops[AppValues.stopsKeys[indexPath.row]]
            }
        }
        previewingContext.sourceRect = cell.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        show(viewControllerToCommit, sender: self)

    }
}
