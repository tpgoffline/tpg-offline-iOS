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
import StoreKit
import Alamofire

struct GoogleMapsGeocodingSearch {
    var address: String
    var stops: [Stop]
}

class StopsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum SearchMode {
        case stops
        case addresses
    }

    var searchMode = SearchMode.stops

    @IBOutlet weak var tableView: UITableView!

    let locationManager = CLLocationManager()
    var searchText = "" {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var addressSearch: GoogleMapsGeocodingSearch?
    var addressRequest: DataRequest?

    var localizedStops: [Stop] = []
    var searchingForNearestStops = false
    let searchController = UISearchController(searchResultsController: nil)
    var askForRating = true

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        searchController.searchBar.placeholder = "Let's take the bus!".localized
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Bus Stop".localized, "Address".localized]
        searchController.searchBar.delegate = self

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        DispatchQueue.main.async {
            Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/stops.json.md5").responseString { (response) in
                if let updatedMD5 = response.result.value, updatedMD5 != UserDefaults.standard.string(forKey: "stops.json.md5") {
                    self.getNewStops(updatedMD5)
                }
            }

            Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json.md5").responseString { (response) in
                if let updatedMD5 = response.result.value, updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5") {
                    UserDefaults.standard.set(true, forKey: "offlineDeparturesUpdateAvailable")
                    let alertController = UIAlertController(title: "New offline departures available".localized, message: "You can download them in Settings".localized, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }

            if #available(iOS 10.3, *), self.askForRating {
                SKStoreReviewController.requestReview()
            }
        }
        
        DispatchQueue.main.async {
            for stop in App.stops where App.indexedStops.index(of: stop.appId) == nil {
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.title = stop.name
                attributeSet.contentDescription = ""
                
                let item = CSSearchableItem(
                    uniqueIdentifier: "\(stop.appId)",
                    domainIdentifier: "com.dacostafaro",
                    attributeSet: attributeSet)
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
            for id in App.indexedStops where App.stops.filter({ $0.appId == id })[safe: 0] == nil {
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(id)"]) { error in
                    if let error = error {
                        print("Deindexing error: \(error.localizedDescription)")
                    } else {
                        print("\(id) successfully removed!")
                    }
                }
            }
        }

        self.tableView.sectionIndexBackgroundColor = .white

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
    }

    func getNewStops(_ updatedMD5: String) {
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/stops.json").responseData { (response) in
            if let stopsData = response.result.value {
                var fileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0])
                fileURL.appendPathComponent("stops.json")

                    UserDefaults.standard.set(stopsData, forKey: "stops.json")
                    UserDefaults.standard.set(updatedMD5, forKey: "stops.json.md5")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        searchForNearestStops()
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

    func lookForAdresses() {
        self.addressRequest?.cancel()
        let requestParameters = [
            "address": searchController.searchBar.text ?? "",
            "key": API.googleMaps,
            "bounds": "46.074183321902574,5.873565673828125|46.37630675382684,6.403656005859375",
            "region": "ch",
            "language": Locale.preferredLanguages[0]
        ]
        self.addressRequest = Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json", method: .get, parameters: requestParameters).responseData(completionHandler: { (response) in
            if let data = response.data {
                let jsonDecoder = JSONDecoder()

                do {
                    let json = try jsonDecoder.decode(GoogleMapsGeocoding.self, from: data)
                    guard let result = json.results[safe: 0] else {
                        return
                    }
                    var localizedStops: [Stop] = []
                    for stop in App.stops {
                        var stopA = stop
                        stopA.distance = result.geometry.location.location.distance(from: stopA.location)
                        localizedStops.append(stopA)
                    }
                    localizedStops.sort(by: { $0.distance < $1.distance })
                    localizedStops = Array(localizedStops.prefix(5))
                    localizedStops = localizedStops.filter({ $0.distance < 1500 })
                    self.addressSearch = GoogleMapsGeocodingSearch(address: result.formattedAddress, stops: localizedStops)
                    self.tableView.reloadData()
                } catch {
                    return
                }
            }
        })
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showStop", searchMode == .addresses, searchText != "", tableView.indexPathForSelectedRow?.row == 0 {
            return false
        }
        return true
    }
}

extension StopsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchText = searchController.searchBar.text ?? ""
        App.log(string: "Stops: Search: \(self.searchText) - \(self.searchMode)")
        if self.searchMode == .addresses {
            lookForAdresses()
        }
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            self.searchMode = .stops
        case 1:
            self.searchMode = .addresses
        default:
            return
        }
        App.log(string: "Stops: Search: \(self.searchText) - \(self.searchMode)")
        if self.searchMode == .addresses {
            lookForAdresses()
        }
        self.tableView.reloadData()
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
            self.localizedStops = self.localizedStops.filter({ $0.distance < 1500 })
            self.tableView.reloadData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
}

extension StopsTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? StopsTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "departuresViewController") as? DeparturesViewController
            else { return nil }

        detailVC.stop = row.stop
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        show(viewControllerToCommit, sender: self)

    }
}

extension StopsTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchText != "" {
            return 1
        }
        return App.sortedStops.keys.count + 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText != "" {
            switch self.searchMode {
            case .stops:
                return searchForStop(searchText.escaped).count
            case .addresses:
                return (self.addressSearch?.stops.count ?? 0) + 1
            }

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

        if self.searchText.escaped != "", searchMode == .addresses, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stopsCell", for: indexPath)

            let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline),
                               NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
            let subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                  NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0

            cell.textLabel?.attributedText = NSAttributedString(string: "Nearest stops from".localized, attributes: titleAttributes)
            cell.detailTextLabel?.attributedText = NSAttributedString(string: addressSearch?.address ?? "", attributes: subtitleAttributes)
            cell.accessoryView = nil

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stopsCell", for: indexPath) as? StopsTableViewCell else {
            return UITableViewCell()
        }

        let stop: Stop
        if self.searchText.escaped != "" {
            switch self.searchMode {
            case .stops:
                stop = searchForStop(searchText.escaped)[indexPath.row]
                cell.isFavorite = false
                cell.isNearestStops = false
            case .addresses:
                guard let a = self.addressSearch?.stops[safe: indexPath.row - 1] else {
                    return UITableViewCell()
                }
                stop = a
                cell.isFavorite = false
                cell.isNearestStops = true
            }
        } else {
            switch indexPath.section {
            case 0:
                stop = localizedStops[indexPath.row]
                cell.isFavorite = false
                cell.isNearestStops = true
            case 1:
                guard let a = App.stops.filter({ (App.favoritesStops[safe: indexPath.row] ?? 0) == $0.appId })[safe: 0] else {
                    return UITableViewCell()
                }
                stop = a
                cell.isFavorite = true
                cell.isNearestStops = false
            default:
                guard let key = App.sortedStops.keys.sorted()[safe: indexPath.section - 2] else {
                    return UITableViewCell()
                }
                guard let name = App.sortedStops[key]?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchText != "" {
            return 0
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
