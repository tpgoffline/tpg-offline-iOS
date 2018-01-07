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

protocol StopSelectionDelegate: class {
    func stopSelected(_ newStop: Stop)
}

class StopsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum SearchMode {
        case stops
        case addresses
    }

    var searchMode: SearchMode = SearchMode.stops

    weak var delegate: StopSelectionDelegate?

    @IBOutlet weak var tableView: UITableView!

    let locationManager = CLLocationManager()
    var searchText: String! = "" {
        didSet {
            self.searchRequest?.cancel()
            self.searchRequest = DispatchWorkItem(flags: .inheritQoS) {
                if let stopCode = App.stops.filter({ $0.code.escaped == self.searchText.escaped })[safe: 0] {
                    self.stopsSearched = [stopCode]
                } else {
                    self.stopsSearched =  App.stops.filter({ $0.name.escaped.contains(self.searchText.escaped) })
                }
            }
            DispatchQueue.main.async(execute: self.searchRequest!)
        }
    }

    var searchRequest: DispatchWorkItem?
    var stopsSearched: [Stop] = [] {
        didSet {
            self.tableView.reloadData()
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

        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        searchController.searchBar.placeholder = "Let's take the bus!".localized
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Bus Stop".localized, "Address".localized]
        searchController.searchBar.delegate = self
        searchController.searchBar.keyboardAppearance = App.darkMode ? .dark : .light

        App.log("Favorites stops: \(App.favoritesStops)")

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            searchController.hidesNavigationBarDuringPresentation = false
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

            Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/lines.json.md5").responseString { (response) in
                if let updatedMD5 = response.result.value, updatedMD5 != UserDefaults.standard.string(forKey: "lines.json.md5") {
                    self.getNewLines(updatedMD5)
                }
            }

            if !(UserDefaults.standard.bool(forKey: "notFirstLaunch")) {
                App.log( "First launch !!!")
                UserDefaults.standard.set(true, forKey: "notFirstLaunch")
            }
            if #available(iOS 10.3, *), self.askForRating {
                SKStoreReviewController.requestReview()

                Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json.md5").responseString { (response) in
                    if let updatedMD5 = response.result.value, updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5"),
                        UserDefaults.standard.bool(forKey: "remindUpdate") == false {
                        UserDefaults.standard.set(true, forKey: "offlineDeparturesUpdateAvailable")
                        UserDefaults.standard.set(true, forKey: "remindUpdate")
                        let alertController = UIAlertController(title: "New offline departures available".localized, message: "You can download them in Settings".localized, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
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

        if App.darkMode {
            self.tableView.sectionIndexBackgroundColor = App.cellBackgroundColor
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.backgroundColor = .black
        }

        ColorModeManager.shared.addColorModeDelegate(self)

        guard let rightNavController = self.splitViewController?.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavController.topViewController as? DeparturesViewController else { return }
        self.delegate = detailViewController
    }

    func getNewStops(_ updatedMD5: String) {
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/stops.json").responseData { (response) in
            if let stopsData = response.result.value {
                UserDefaults.standard.set(stopsData, forKey: "stops.json")
                UserDefaults.standard.set(updatedMD5, forKey: "stops.json.md5")
            }
        }
    }

    func getNewLines(_ updatedMD5: String) {
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/lines.json").responseData { (response) in
            if let stopsData = response.result.value {
                UserDefaults.standard.set(stopsData, forKey: "lines.json")
                UserDefaults.standard.set(updatedMD5, forKey: "lines.json.md5")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        searchForNearestStops()
    }

    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    func searchForNearestStops() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func presentStopFromAppDelegate(stop: Stop) {
        self.delegate?.stopSelected(stop)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        if let detailViewController = delegate as? DeparturesViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            detailNavigationController.popToRootViewController(animated: false)
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
        self.addressRequest = Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json",
                                                method: .get,
                                                parameters: requestParameters)
            .responseData(completionHandler: { (response) in
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

    override func colorModeDidUpdated() {
        super.colorModeDidUpdated()
        self.tableView.backgroundColor = App.darkMode ? .black : .groupTableViewBackground
        self.tableView.sectionIndexBackgroundColor = App.darkMode ? .black : .white
        self.tableView.separatorColor = App.separatorColor
        self.tableView.reloadData()
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }
}

extension StopsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        App.log( "Stops: Search: \(self.searchText) - \(self.searchMode)")
        self.searchText = searchController.searchBar.text ?? ""
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
        App.log( "Stops: Search: \(self.searchText) - \(self.searchMode)")
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
                return stopsSearched.count
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

        if self.searchText.escaped != "", self.searchMode == .addresses, indexPath.row == 0 {
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
                stop = stopsSearched[indexPath.row]
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
            headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1)
            let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                   NSAttributedStringKey.foregroundColor: App.darkMode ? #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1) : UIColor.white] as [NSAttributedStringKey: Any]
            headerCell?.textLabel?.attributedText = NSAttributedString(string: "Nearest stops".localized, attributes: titleAttributes)

        } else if section == 1 {
            headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.09411764706, green: 0.7019607843, blue: 0.3921568627, alpha: 1)
            headerCell?.textLabel?.text = "Favorites".localized
            let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                   NSAttributedStringKey.foregroundColor: App.darkMode ? #colorLiteral(red: 0.09411764706, green: 0.7019607843, blue: 0.3921568627, alpha: 1) : UIColor.white] as [NSAttributedStringKey: Any]
            headerCell?.textLabel?.attributedText = NSAttributedString(string: "Favorites".localized, attributes: titleAttributes)
        } else {
            headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
            let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                   NSAttributedStringKey.foregroundColor: App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : UIColor.white] as [NSAttributedStringKey: Any]
            headerCell?.textLabel?.attributedText =
                NSAttributedString(string: App.sortedStops.keys.sorted()[section - 2], attributes: titleAttributes)
        }

        return headerCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.searchBar.resignFirstResponder()
        self.tableView.deselectRow(at: indexPath, animated: true)
        guard let stop = (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?.stop else {
            return
        }
        self.delegate?.stopSelected(stop)

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        if let detailViewController = delegate as? DeparturesViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            detailNavigationController.popToRootViewController(animated: false)
        }
    }
}

extension StopsTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
