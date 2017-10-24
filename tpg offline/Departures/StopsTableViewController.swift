//
//  StopsTableViewController.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 09/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit
import CoreLocation
import CoreSpotlight
import MobileCoreServices

class StopsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let locationManager = CLLocationManager()
    var searchText = "" {
        didSet {
            self.tableView.reloadData()
        }
    }
    var localizedStops: [Stop] = []
    var searchingForNearestStops = false
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        searchController.searchBar.placeholder = "Let's take the bus!".localized
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        DispatchQueue.main.async {
            for stop in App.stops {
                if App.indexedStops.index(of: stop.appId) == nil {
                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                    attributeSet.title = stop.name
                    attributeSet.contentDescription = ""

                    let item = CSSearchableItem(uniqueIdentifier: "\(stop.appId)", domainIdentifier: "com.dacostafaro", attributeSet: attributeSet)
                    item.expirationDate = Date.distantFuture
                    CSSearchableIndex.default().indexSearchableItems([item]) { error in
                        if let error = error {
                            print("Indexing error: \(error.localizedDescription)")
                        } else {
                            print("\(stop.appId) successfully indexed!")
                        }
                    }
                    App.indexedStops.append(stop.appId)
                }
            }
            for id in App.indexedStops {
                if App.stops.filter({ $0.appId == id })[safe: 0] == nil {
                    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(id)"]) { error in
                        if let error = error {
                            print("Deindexing error: \(error.localizedDescription)")
                        } else {
                            print("\(id) successfully removed!")
                        }
                    }
                }
            }
        }

        self.tableView.sectionIndexBackgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        searchForNearestStops()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func searchForNearestStops() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func presentStopFromAppDelegate(stop: Stop) {
        performSegue(withIdentifier: "manualShowStop", sender: stop)
    }

    func searchForStop(_ fromText: String) -> [Stop] {
        if let stopCode = App.stops.filter({ $0.code.escaped == searchText.escaped })[safe: 0] {
            return [stopCode]
        } else {
            return App.stops.filter({ $0.name.escaped.contains(searchText.escaped) })
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        if searchText != "" {
            return 1
        }
        return App.sortedStops.keys.count + 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText != "" {
            return searchForStop(searchText.escaped).count
        }
        switch section {
        case 0:
            return localizedStops.count
        case 1:
            return App.favoritesStops.count
        default:
            return App.sortedStops[App.sortedStops.keys.sorted()[section - 2]]?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stopsCell", for: indexPath) as? StopsTableViewCell else {
            return UITableViewCell()
        }

        let stop: Stop
        if searchText != "" {
            stop = searchForStop(searchText.escaped)[indexPath.row]
            cell.isFavorite = false
            cell.isNearestStops = false
        } else {
            switch indexPath.section {
            case 0:
                stop = localizedStops[indexPath.row]
                cell.isFavorite = false
                cell.isNearestStops = true
            case 1:
                stop = App.stops.filter({ App.favoritesStops[indexPath.row] == $0.appId })[0]
                cell.isFavorite = true
                cell.isNearestStops = false
            default:
                let name = App.sortedStops[App.sortedStops.keys.sorted()[indexPath.section - 2]]![indexPath.row]
                stop = App.stops.filter({$0.name == name})[0]
                cell.isFavorite = false
                cell.isNearestStops = false
            }
        }

        cell.configure(with: stop)

        return cell
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return App.sortedStops.keys.sorted()
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 2
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStop" {
            self.searchController.searchBar.resignFirstResponder()
            guard let destinationViewController = segue.destination as? DeparturesViewController else {
                return
            }
            let indexPath = tableView.indexPathForSelectedRow!
            self.tableView.deselectRow(at: indexPath, animated: true)
            destinationViewController.stop = (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?
                .stop
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        } else if segue.identifier == "manualShowStop" {
            guard let destinationViewController = segue.destination as? DeparturesViewController else {
                return
            }
            guard let stop = sender as? Stop else {
                return
            }
            destinationViewController.stop = stop
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchText != "" {
            return 0
        } else if section == 0 {
            return self.localizedStops.isEmpty ? 0 : 28
        } else {
            return 28
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "stopsHeader")

        if searchText != "" {
            return nil
        }
        if section == 0 {
            headerCell?.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1)
            headerCell?.textLabel?.text = "Nearest stops".localized
            if self.localizedStops.isEmpty { return nil }
        } else if section == 1 {
            headerCell?.backgroundColor = #colorLiteral(red: 0.09411764706, green: 0.7019607843, blue: 0.3921568627, alpha: 1)
            headerCell?.textLabel?.text = "Favorites".localized
        } else {
            headerCell?.backgroundColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
            headerCell?.textLabel?.text = App.sortedStops.keys.sorted()[section - 2]
        }
        headerCell?.textLabel?.textColor = .white

        return headerCell
    }
}

/*extension StopsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
*/
extension StopsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchText = searchController.searchBar.text ?? ""
    }
}

extension StopsTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations[safe: 0] {
            self.localizedStops.removeAll()
            for stop in App.stops {
                var stopA = stop
                stopA.distance = location.distance(from: stopA.location)
                self.localizedStops.append(stopA)
            }
            self.localizedStops.sort(by: { $0.distance < $1.distance })
            self.localizedStops = Array(self.localizedStops.prefix(5))
            self.tableView.reloadData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
}
