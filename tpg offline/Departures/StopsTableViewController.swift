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
import Solar

struct GoogleMapsGeocodingSearch {
  var address: String
  var stops: [Stop]
  var location: CLLocation
}

protocol StopSelectionDelegate: class {
  func stopSelected(_ newStop: Stop)
}

class StopsTableViewController: UIViewController {

  enum SearchMode {
    case stops
    case addresses
  }

  var searchMode: SearchMode = SearchMode.stops

  weak var delegate: StopSelectionDelegate?

  @IBOutlet weak var tableView: UITableView!
  var canRefreshLocationInTableView = true

  let locationManager = CLLocationManager()
  var searchText: String! = "" {
    didSet {
      self.searchRequest?.cancel()
      self.searchRequest = DispatchWorkItem(flags: .inheritQoS) {
        var stops = App.stops.filter({
          $0.name.escaped.contains(self.searchText.escaped)
        })
        if let stopCode = App.stops.filter({
          $0.code.escaped == self.searchText.escaped
        })[safe: 0] {
          stops.removeAll(where: { $0.code == stopCode.code })
          stops.insert(stopCode, at: 0)
        }
        self.stopsSearched = stops
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

    if !CommandLine.arguments.contains("-reset") {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    searchController.searchBar.placeholder = Text.letsTakeTheBus
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.scopeButtonTitles = [Text.busStop,
                                                    Text.address]
    searchController.searchBar.delegate = self
    searchController.searchBar.keyboardAppearance = App.darkMode ? .dark : .light

    App.log("TableView Keys: \(App.stopsKeys)")
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
      Alamofire.request(URL.stopsMD5).responseString { (response) in
        if let updatedMD5 = response.result.value,
          updatedMD5 != UserDefaults.standard.string(forKey: "stops.json.md5") {
          self.getNewStops(updatedMD5)
        }
      }

      Alamofire.request(URL.linesMD5).responseString { (response) in
        if let updatedMD5 = response.result.value,
          updatedMD5 != UserDefaults.standard.string(forKey: "lines.json.md5") {
          self.getNewLines(updatedMD5)
        }
      }

      if !(UserDefaults.standard.bool(forKey: "notFirstLaunch")) {
        App.log("First launch !!!")
        UserDefaults.standard.set(true, forKey: "notFirstLaunch")
      }
      if #available(iOS 10.3, *), self.askForRating {
        #if DEBUG
        print("DEBUG MODE: SKStoreReviewController not activated")
        #else
        SKStoreReviewController.requestReview()
        #endif

        OfflineDeparturesManager.shared.checkUpdate(viewController: self)
      }
    }

    DispatchQueue.main.async {
      for stop in App.stops where App.indexedStops.index(of: stop.appId) == nil {
        let attributeSet =
          CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
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

      for id in App.indexedStops where App.stops.filter({
        $0.appId == id
      })[safe: 0] == nil {
        CSSearchableIndex.default()
          .deleteSearchableItems(withIdentifiers: ["\(id)"]) { error in
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
      navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedStringKey.foregroundColor: App.textColor]
    }

    navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: App.textColor]

    if App.darkMode {
      self.tableView.sectionIndexBackgroundColor = App.cellBackgroundColor
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.backgroundColor = .black
    }

    ColorModeManager.shared.addColorModeDelegate(self)

    guard let rightNavController =
        self.splitViewController?.viewControllers.last as? UINavigationController,
      let detailViewController = rightNavController.topViewController
        as? DeparturesViewController else { return }
    self.delegate = detailViewController
  }

  func getNewStops(_ updatedMD5: String) {
    Alamofire.request(URL.stops).responseData { (response) in
      if let stopsData = response.result.value {
        UserDefaults.standard.set(stopsData, forKey: "stops.json")
        UserDefaults.standard.set(updatedMD5, forKey: "stops.json.md5")
      }
    }
  }

  func getNewLines(_ updatedMD5: String) {
    Alamofire.request(URL.lines).responseData { (response) in
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
      splitViewController?.showDetailViewController(detailNavigationController,
                                                    sender: nil)
      detailNavigationController.popToRootViewController(animated: false)
    }
  }

  func lookForAdresses() {
    self.addressRequest?.cancel()
    let requestParameters = [
      "address": searchController.searchBar.text ?? "",
      "key": API.googleMaps,
      "bounds": "46.074183321902,5.873565673828|46.37630675382,6.403656005859",
      "region": "ch",
      "language": Locale.preferredLanguages[0]
    ]
    self.addressRequest = Alamofire.request(URL.googleMapsGeocode,
                                            method: .get,
                                            parameters: requestParameters)
      .responseData(completionHandler: { (response) in
        if let data = response.data {
          let jsonDecoder = JSONDecoder()

          do {
            let json = try jsonDecoder.decode(GoogleMapsGeocoding.self,
                                              from: data)
            guard let result = json.results[safe: 0] else {
              return
            }
            var localizedStops: [Stop] = []
            for stop in App.stops {
              var stopA = stop
              stopA.distance = result.geometry.location.location
                .distance(from: stopA.location)
              localizedStops.append(stopA)
            }
            localizedStops.sort(by: { $0.distance < $1.distance })
            localizedStops = Array(localizedStops.prefix(5))
            localizedStops = localizedStops.filter({ $0.distance < 1500 })
            self.addressSearch =
              GoogleMapsGeocodingSearch(address: result.formattedAddress,
                                        stops: localizedStops,
                                        location: result.geometry.location.location)
            self.tableView.reloadData()
          } catch {
            return
          }
        }
      })
  }

  override func shouldPerformSegue(withIdentifier identifier: String,
                                   sender: Any?) -> Bool {
    if identifier == "showStop",
      searchMode == .addresses,
      searchText != "",
      tableView.indexPathForSelectedRow?.row == 0 {
      return false
    }
    return true
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.searchController.searchBar.keyboardAppearance =
      App.darkMode ? .dark : .light
    self.tableView.backgroundColor =
      App.darkMode ? .black : .groupTableViewBackground
    self.tableView.sectionIndexBackgroundColor = App.darkMode ? .black : .white
    self.tableView.separatorColor = App.separatorColor
    self.tableView.reloadData()
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension StopsTableViewController: UISearchResultsUpdating,
                                    UISearchBarDelegate {
  func updateSearchResults(for searchController: UISearchController) {
    let text = searchController.searchBar.text ?? ""
    App.log("Stops: Search: \(text) - \(self.searchMode)")
    self.searchText = text
    if self.searchMode == .addresses {
      lookForAdresses()
    }
  }

  func searchBar(_ searchBar: UISearchBar,
                 selectedScopeButtonIndexDidChange selectedScope: Int) {
    switch selectedScope {
    case 0:
      self.searchMode = .stops
      canRefreshLocationInTableView = true
    case 1:
      self.searchMode = .addresses
      canRefreshLocationInTableView = false
    default:
      return
    }
    App.log("Stops: Search: \(self.searchText ?? "") - \(self.searchMode)")
    if self.searchMode == .addresses {
      lookForAdresses()
    }
    self.tableView.reloadData()
  }
}

extension StopsTableViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    if let location = locations[safe: 0] {
      App.sunriseSunsetManager = Solar(coordinate: location.coordinate)
      self.localizedStops.removeAll()
      for stop in App.stops {
        var stopA = stop
        stopA.distance = location.distance(from: stopA.location)
        self.localizedStops.append(stopA)
      }
      self.localizedStops.sort(by: { $0.distance < $1.distance })
      self.localizedStops = Array(self.localizedStops.prefix(5))
      self.localizedStops = self.localizedStops.filter({ $0.distance < 1500 })
      if canRefreshLocationInTableView {
        self.tableView.reloadData()
      }
    }
  }

  func locationManager(_ manager: CLLocationManager,
                       didFailWithError error: Error) {
    print("Error")
  }
}

extension StopsTableViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    // swiftlint:disable:previous line_length

    guard let indexPath = tableView.indexPathForRow(at: location)
      else { return nil }

    guard let row = tableView.cellForRow(at: indexPath) as? StopsTableViewCell
      else { return nil }

    let viewControllerId = "departuresViewController"
    guard let detailVC =
      storyboard?.instantiateViewController(withIdentifier: viewControllerId)
        as? DeparturesViewController
      else { return nil }

    detailVC.stop = row.stop
    previewingContext.sourceRect = row.frame
    return detailVC
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
}

extension StopsTableViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    if searchText != "" {
      return 1
    }
    return App.stopsKeys.count
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if searchText != "" {
      switch self.searchMode {
      case .stops:
        return stopsSearched.count
      case .addresses:
        return (self.addressSearch?.stops.count ?? 0) + 1
      }

    }
    let key = App.stopsKeys[section]
    switch key {
    case "location":
      return localizedStops.count
    case "favorites":
      return App.favoritesStops.count
    default:
      return App.sortedStops[key]?.count ?? 0
    }
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.searchText.escaped != "",
      self.searchMode == .addresses,
      indexPath.row == 0 {
      let cellId = "addressHeaderCell"
      guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                     for: indexPath)
        as? AddressHeaderTableViewCell else {
          return UITableViewCell()
      }

      cell.search = self.addressSearch
      cell.accessoryType = .none

      return cell
    }

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "stopsCell",
                                                   for: indexPath)
      as? StopsTableViewCell else {
      return UITableViewCell()
    }

    let stop: Stop
    if self.searchText.escaped != "" {
      switch self.searchMode {
      case .stops:
        guard let stopA = stopsSearched[safe: indexPath.row]
          else { return UITableViewCell() }
        stop = stopA
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
      let key = App.stopsKeys[indexPath.section]
      switch key {
      case "location":
        guard let stopA = localizedStops[safe: indexPath.row]
          else { return UITableViewCell() }
        stop = stopA
        cell.isFavorite = false
        cell.isNearestStops = true
      case "favorites":
        guard let a = App.stops.filter({
          (App.favoritesStops[safe: indexPath.row] ?? 0) == $0.appId
        })[safe: 0] else {
          return UITableViewCell()
        }
        stop = a
        cell.isFavorite = true
        cell.isNearestStops = false
      default:
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
    var a = App.stopsKeys
    if let location = App.stopsKeys.index(of: "location") {
      a[location] = "📍"
    }
    if let favorites = App.stopsKeys.index(of: "favorites") {
      a[favorites] = "⭐️"
    }
    return a
  }

  func tableView(_ tableView: UITableView,
                 sectionForSectionIndexTitle title: String,
                 at index: Int) -> Int {
    return index
  }

  func tableView(_ tableView: UITableView,
                 heightForHeaderInSection section: Int) -> CGFloat {
    if searchText != "" {
      return CGFloat.leastNonzeroMagnitude
    } else {
      return 28
    }
  }

  func tableView(_ tableView: UITableView,
                 viewForHeaderInSection section: Int) -> UIView? {
    let headerCell = tableView.dequeueReusableCell(withIdentifier: "stopsHeader")

    if searchText != "" {
      return nil
    }
    let key = App.stopsKeys[section]
    let font = UIFont.preferredFont(forTextStyle: .headline)
    if key == "location" {
      headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1)
      let titleAttributes = [NSAttributedStringKey.font: font,
                             NSAttributedStringKey.foregroundColor:
                              App.darkMode ? #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1) : UIColor.white]
        as [NSAttributedStringKey: Any]
      headerCell?.textLabel?.attributedText =
        NSAttributedString(string: Text.nearestStops,
                           attributes: titleAttributes)

    } else if key == "favorites" {
      headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.09411764706, green: 0.7019607843, blue: 0.3921568627, alpha: 1)
      let titleAttributes = [NSAttributedStringKey.font: font,
                             NSAttributedStringKey.foregroundColor:
                              App.darkMode ? #colorLiteral(red: 0.09411764706, green: 0.7019607843, blue: 0.3921568627, alpha: 1) : UIColor.white]
        as [NSAttributedStringKey: Any]
      headerCell?.textLabel?.attributedText =
        NSAttributedString(string: Text.favorites,
                           attributes: titleAttributes)
    } else {
      headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
      let titleAttributes = [NSAttributedStringKey.font: font,
                             NSAttributedStringKey.foregroundColor:
                              App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : UIColor.white]
        as [NSAttributedStringKey: Any]
      headerCell?.textLabel?.attributedText =
        NSAttributedString(string: key, attributes: titleAttributes)
    }

    return headerCell
  }

  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    self.searchController.searchBar.resignFirstResponder()
    self.tableView.deselectRow(at: indexPath, animated: true)

    if self.searchText.escaped != "",
      self.searchMode == .addresses,
      indexPath.row == 0 {
      return
    }
    guard let stop =
      (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?.stop else {
      return
    }
    self.delegate?.stopSelected(stop)

    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem

    if let detailViewController = delegate as? DeparturesViewController,
      let detailNavigationController = detailViewController.navigationController {
      splitViewController?.showDetailViewController(detailNavigationController,
                                                    sender: nil)
      detailNavigationController.popToRootViewController(animated: false)
    }
  }

  func tableView(_ tableView: UITableView,
                 canEditRowAt indexPath: IndexPath) -> Bool {
    return !(
      searchMode == .addresses &&
      searchText.escaped != "" &&
      indexPath.row == 0)
  }

  func tableView(_ tableView: UITableView,
                 willBeginEditingRowAt indexPath: IndexPath) {
    canRefreshLocationInTableView = false
  }

  func tableView(_ tableView: UITableView,
                 didEndEditingRowAt indexPath: IndexPath?) {
    canRefreshLocationInTableView = true
  }

  func tableView(_ tableView: UITableView,
                 editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    // swiftlint:disable:previous line_length
    let favoriteAction = UITableViewRowAction(style: .normal,
                                              title: Text.favorites) {_, _ in
      guard let stop =
        (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?.stop else {
        return
      }
      if let index = App.favoritesStops.index(of: stop.appId) {
        App.favoritesStops.remove(at: index)
        App.log("Removed \(stop.appId) from favorites")
      } else {
        App.favoritesStops.append(stop.appId)
        App.log("Added \(stop.appId) from favorites")
      }

      self.tableView.reloadData()
    }
    if App.darkMode {
      favoriteAction.backgroundColor = .black
    } else {
      favoriteAction.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
    }
    return [favoriteAction]
  }
}

extension StopsTableViewController: UISplitViewControllerDelegate {
  func splitViewController(_ splitViewController: UISplitViewController,
                           collapseSecondary secondaryViewController: UIViewController, //swiftlint:disable:this line_length
                           onto primaryViewController: UIViewController) -> Bool {
    return true
  }
}
