//
//  DeparturesViewController.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 10/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit
import Mapbox
import Alamofire
import UserNotifications
import MessageUI
import Intents
#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

class DeparturesViewController: UIViewController {

  @IBOutlet weak var mapView: MGLMapView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var stackView: UIStackView!

  var stop: Stop? {
    didSet {
      guard let stop = stop else { return }
      App.log("Departures: Selected \(stop.code)")
      App.logEvent("Show departures",
                   attributes: ["appId": stop.code])

      navigationItem.title = stop.name
      navigationItem.accessibilityTraits = UIAccessibilityTraits.none
      refreshDepatures()

      configureTabBarItems()
      loadMap()

      // Siri Intent
      if #available(iOS 12.0, *) {
        let interaction = INInteraction(intent: stop.intent, response: nil)
        interaction.donate { (error) in
          if let error = error {
            print(error.localizedDescription)
          }
        }
      }
    }
  }
  var departures: DeparturesGroup?
  var filteredLines: [String] = []
  var showMoreLines: [String] = []
  var noInternet = false
  var requestStatus: RequestStatus = .loading {
    didSet {
      guard let tableView = self.tableView else { return }
      tableView.allowsSelection = requestStatus == .ok
      tableView.reloadData()
    }
  }

  private let refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()

    if self.stop == nil {
      self.stop = App.stops[0]
    }

    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      self.tableView.addSubview(refreshControl)
    }

    refreshControl.addTarget(self, action: #selector(refreshDepatures),
                             for: .valueChanged)
    refreshControl.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

    self.mapView.isHidden = true

    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 62

    if self.view.traitCollection.verticalSizeClass == .compact,
      UIDevice.current.userInterfaceIdiom == .phone {
      self.stackView.axis = .horizontal
    } else {
      self.stackView.axis = .vertical
    }

    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }

    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
      self.view.backgroundColor = .black
    }

    mapView.delegate = self
    loadMap()

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func configureTabBarItems() {
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: App.filterFavoritesLines ? #imageLiteral(resourceName: "filter") : #imageLiteral(resourceName: "filterEmpty"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.toggleFilterFavoritesLines),
                      accessbilityLabel: "Filter favorites lines".localized),
      UIBarButtonItem(image: App.favoritesStops.contains(stop!.appId) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "starEmpty"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.setFavorite),
                      accessbilityLabel: App.favoritesStops.contains(stop!.appId) ?
                        "Unmark this stop as favorite".localized :
                        "Mark this stop as favorite".localized),
      UIBarButtonItem(image: #imageLiteral(resourceName: "pinMapNavBar"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.showMap),
                      accessbilityLabel: "Show map".localized),
      UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.reload),
                      accessbilityLabel: "Reload departures".localized)
    ]
  }

  @objc func refreshDepatures() {
    self.departures = nil
    self.requestStatus = .loading
    self.noInternet = false
    Alamofire.request(URL.departures(with: stop!.code), method: .get)
      .responseData { (response) in
        if let data = response.result.value {
          var options = DeparturesOptions()
          options.networkStatus = .online
          let jsonDecoder = JSONDecoder()
          jsonDecoder.userInfo = [DeparturesOptions.key: options]
          do {
            let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
            self.departures = json
            self.filteredLines = json.lines.filter({
              App.favoritesLines.contains($0)
            })
            self.requestStatus = .ok
          } catch {
            self.noInternet = true
            if let sbbId = self.stop?.sbbId {
              (self.departures, self.requestStatus, self.filteredLines) =
                OfflineDeparturesManager.shared.loadDepartures(sbbId)
            }
          }

          if self.departures?.lines.count == 0 {
            self.requestStatus = .noResults
          }
        } else {
          self.noInternet = true
          if let sbbId = self.stop?.sbbId {
            (self.departures, self.requestStatus, self.filteredLines) =
              OfflineDeparturesManager.shared.loadDepartures(sbbId)
          }
        }
        self.refreshControl.endRefreshing()
    }
  }

  @objc func toggleFilterFavoritesLines() {
    App.filterFavoritesLines = !(App.filterFavoritesLines)
    self.configureTabBarItems()
    showMoreLines = []
    self.filteredLines = self.departures?.lines.filter({
      App.favoritesLines.contains($0)
    }) ?? []
    self.tableView.reloadData()
  }

  @objc func reload() {
    refreshDepatures()
  }

  @objc func showMap() {
    self.mapView.isHidden = !self.mapView.isHidden
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()

    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)

    self.tableView.backgroundColor = App.darkMode ? .black :
                                                    .groupTableViewBackground
    self.tableView.separatorColor = App.separatorColor
    self.tableView.reloadData()
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDeparturesDetail" {
      guard let destinationViewController = segue.destination
        as? DetailDeparturesViewController else {
        return
      }
      let indexPath = tableView.indexPathForSelectedRow!
      guard let row = tableView.cellForRow(at: indexPath)
        as? DeparturesTableViewCell else {
        return
      }
      destinationViewController.color =
        LineColorManager.color(for: row.departure!.line.code)
      destinationViewController.departure = row.departure
      destinationViewController.stop = self.stop
      App.log(String(format: "Departures: Select %@ - %@ - %@",
                     row.departure?.line.code ?? "",
                     row.departure?.line.destination ?? "",
                     row.departure?.timestamp ?? ""))
      tableView.deselectRow(at: indexPath, animated: true)
    }
    if segue.identifier == "showConnectionsMap" {
      guard let destinationViewController = segue.destination
        as? ConnectionsMapViewController else {
        return
      }
      destinationViewController.stopCode = self.stop?.code ?? ""
      if let indexPath = tableView.indexPathForSelectedRow {
        tableView.deselectRow(at: indexPath, animated: true)
      }
    }
  }

  @objc func setFavorite() {
    if let index = App.favoritesStops.index(of: stop!.appId) {
      App.favoritesStops.remove(at: index)
      App.log("Removed \(stop!.appId) from favorites")
    } else {
      App.favoritesStops.append(stop!.appId)
      App.log("Added \(stop!.appId) from favorites")
    }
    configureTabBarItems()
    guard let vc = ((splitViewController?.viewControllers.first
      as? UINavigationController)?.topViewController
      as? StopsTableViewController) else {
        return
    }
    vc.tableView.reloadData()
  }

  // swiftlint:disable:next line_length
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    if self.view.traitCollection.verticalSizeClass == .compact,
      UIDevice.current.userInterfaceIdiom == .phone {
      self.stackView.axis = .horizontal
    } else {
      self.stackView.axis = .vertical
    }
  }

  func loadMap() {
    guard let mapView = self.mapView else { return }
    guard let stop = self.stop else { return }
    if let annotations = mapView.annotations {
      mapView.removeAnnotations(annotations)
    }

    let stopCoordinate = stop.location.coordinate
    mapView.setCenter(stopCoordinate, zoomLevel: 14, animated: false)

    if !stop.localisations.isEmpty {
      for localisation in stop.localisations {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = localisation.location.coordinate
        annotation.title = stop.name
        var subtitle = ""
        for (index, destination) in localisation.destinations.enumerated() {
          subtitle.append(
            Text.line(destination.line,
                      destination: destination.destination))
          if index != localisation.destinations.count - 1 {
            subtitle.append("\n")
          }
        }
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
      }
    } else {
      let annotation = MGLPointAnnotation()
      annotation.coordinate = stop.location.coordinate
      annotation.title = stop.name
      mapView.addAnnotation(annotation)
    }

    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
  }
}

extension DeparturesViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    if self.requestStatus == .loading {
      return 1
    } else if self.requestStatus == any(of: .error, .noResults) {
      return 2
    } else {
      let addSiri: Int
      if #available(iOS 12.0, *) {
        addSiri = 1
      } else {
        addSiri = 0
      }
      if App.filterFavoritesLines {
        return (self.filteredLines.count) + 3 + addSiri
      } else {
        return (self.departures?.lines.count ?? 0) + 3 + addSiri
      }
    }
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if self.requestStatus == .loading {
      return 5
    } else if self.requestStatus == any(of: .error, .noResults) {
      return 1
    }
    if #available(iOS 12.0, *),
      ((self.requestStatus == any(of: .error, .noResults) && section == 1)
        || (section == ((App.filterFavoritesLines ? self.filteredLines : self.departures?.lines ?? []).count) + 3)) {
      // swiftlint:disable:previous line_length
      return 1
    }
    switch section {
    case 0:
      return self.noInternet ? 1 : 0
    case 1:
      return App.filterFavoritesLines ? 1 : 0
    case 2:
      return (self.stop?.connectionsMap ?? false) ? 1 : 0
    case (self.departures?.lines.count ?? 0) + 3:
      return 1
    default:
      let section = section - 3
      if App.filterFavoritesLines {
        if let count = departures?.departures.filter({
          $0.line.code == (self.filteredLines[section])
        }).count {
          if count > 5 && !(showMoreLines.contains(String(section))) {
            return 4
          } else {
            return count
          }
        } else {
          return 0
        }
      } else {
        if let count = departures?.departures.filter({
          $0.line.code == (self.departures?.lines[section] ?? "")
        }).count {
          if count > 5 && !(showMoreLines.contains(String(section))) {
            return 4
          } else {
            return count
          }
        } else {
          return 0
        }
      }
    }
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.requestStatus == .loading {
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: "departureCell",
        for: indexPath) as? DeparturesTableViewCell else {
          return UITableViewCell()
      }
      cell.departure = nil
      return cell
    } else if self.requestStatus == .error && indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell",
                                               for: indexPath)
      cell.imageView?.image = #imageLiteral(resourceName: "globe").maskWith(color: App.textColor)
      cell.textLabel?.text = Text.error
      cell.detailTextLabel?.text = Text.offlineDeparturesNotDownloaded
      cell.textLabel?.textColor = App.textColor
      cell.detailTextLabel?.textColor = App.textColor
      cell.backgroundColor = App.cellBackgroundColor
      return cell
    } else if self.requestStatus == .noResults && indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell",
                                               for: indexPath)
      cell.imageView?.image = #imageLiteral(resourceName: "warningSign").maskWith(color: App.textColor)
      cell.textLabel?.text = Text.thatsAllForToday
      cell.detailTextLabel?.text = Text.noBusWillCome
      cell.textLabel?.textColor = App.textColor
      cell.detailTextLabel?.textColor = App.textColor
      cell.backgroundColor = App.cellBackgroundColor
      return cell
    } else if #available(iOS 12.0, *),
      ((self.requestStatus == any(of: .error, .noResults) && indexPath.section == 1)
        || (indexPath.section == ((App.filterFavoritesLines ? self.filteredLines : self.departures?.lines ?? []).count) + 3)) {
      // swiftlint:disable:previous line_length
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "siriCell",
                                                     for: indexPath)
        as? AddToSiriTableViewCell,
        let stop = self.stop else {
          return UITableViewCell()
      }
      cell.parent = self
      cell.shortcut = INShortcut(intent: stop.intent)
      return cell
    } else if indexPath.section == 2 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "connectionCell",
                                               for: indexPath)
      cell.imageView?.image = #imageLiteral(resourceName: "transfer").maskWith(color: App.textColor)
      cell.textLabel?.text = Text.connectionsMap
      cell.textLabel?.textColor = App.textColor
      cell.backgroundColor = App.cellBackgroundColor
      cell.accessoryType = .disclosureIndicator
      if App.darkMode {
        let selectedView = UIView()
        selectedView.backgroundColor = .black
        cell.selectedBackgroundView = selectedView
      }
      return cell
    } else if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell",
                                               for: indexPath)
      cell.imageView?.image = #imageLiteral(resourceName: "filter").maskWith(color: App.textColor)
      cell.textLabel?.text = "Filter activated".localized
      cell.textLabel?.textColor = App.textColor
      cell.backgroundColor = App.cellBackgroundColor
      cell.accessoryType = .none
      if App.darkMode {
        let selectedView = UIView()
        selectedView.backgroundColor = .black
        cell.selectedBackgroundView = selectedView
      }
      return cell
    } else if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell",
                                               for: indexPath)
      cell.imageView?.image = #imageLiteral(resourceName: "globe").maskWith(color: App.textColor)
      cell.textLabel?.text = Text.offlineMode
      cell.detailTextLabel?.text = Text.timetablesDepartures
      cell.textLabel?.textColor = App.textColor
      cell.detailTextLabel?.textColor = App.textColor
      cell.backgroundColor = App.cellBackgroundColor
      return cell
    }
    let section = indexPath.section - 3
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell",
                                                   for: indexPath)
      as? DeparturesTableViewCell else {
        return UITableViewCell()
    }

    let departure: Departure?
    if App.filterFavoritesLines {
      departure = departures?.departures.filter({
        $0.line.code == (self.filteredLines[section])
      })[indexPath.row]
    } else {
      departure = departures?.departures.filter({
        $0.line.code == (self.departures?.lines[section] ?? "")
      })[indexPath.row]
    }
    cell.stop = self.stop
    cell.departure = departure
    return cell
  }

  func tableView(_ tableView: UITableView,
                 viewForFooterInSection section: Int) -> UIView? {
    if self.requestStatus == .loading {
      return nil
    } else if self.requestStatus == any(of: .error, .noResults) {
      return nil
    } else if section == any(of: 0, 1, 2) {
      return nil
    } else if #available(iOS 12.0, *),
      ((self.requestStatus == any(of: .error, .noResults) && section == 1)
        || (section == ((App.filterFavoritesLines ? self.filteredLines : self.departures?.lines ?? []).count) + 3)) {
      // swiftlint:disable:previous line_length
      return nil
    }
    let section = section - 3
    var line = self.departures?.lines[safe: section] ?? "?#!"
    if App.filterFavoritesLines {
      line = self.filteredLines[section]
    }
    let count = departures!.departures.filter({$0.line.code == line}).count
    if count > 5 {
      let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "footerCell")
      guard let footerCell = dequeuedCell as? FooterDeparturesTableViewCell
        else { return nil }

      let footerAction = #selector(self.addRemoveFromShowMore(button:))
      let color = LineColorManager.color(for: line,
                                         operator: self.stop?.lines[line] ?? .tpg)

      if showMoreLines.contains(String(section)) {
        footerCell.button.setTitle("Show less".localized, for: .normal)
      } else {
        footerCell.button.setTitle("Show more".localized, for: .normal)
      }
      footerCell.button.setTitleColor(App.darkMode ? color : color.contrast,
                                      for: .normal)
      footerCell.button.tag = section
      footerCell.button.addTarget(self,
                                  action: footerAction,
                                  for: .touchUpInside)
      footerCell.button.backgroundColor = App.darkMode ?
                                          App.cellBackgroundColor : color
      return footerCell
    }
    return nil
  }

  @objc func addRemoveFromShowMore(button: UIButton!) {
    if let index = showMoreLines.index(of: String(button.tag)) {
      showMoreLines.remove(at: index)
    } else {
      showMoreLines.append(String(button.tag))
    }
    tableView.reloadData()
  }

  func tableView(_ tableView: UITableView,
                 viewForHeaderInSection section: Int) -> UIView? {
    if self.requestStatus == .loading {
      let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
      guard let headerCell = dequeuedCell as? DeparturesHeaderTableViewCell else {
        return UIView()
      }
      headerCell.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
      headerCell.titleLabel?.text = ""
      return headerCell
    } else if self.requestStatus == any(of: .error, .noResults) {
      return nil
    } else if section == any(of: 0, 1, 2) {
      return nil
    } else if #available(iOS 12.0, *),
      ((self.requestStatus == any(of: .error, .noResults) && section == 1) ||
        (section == ((App.filterFavoritesLines ? self.filteredLines : self.departures?.lines ?? []).count) + 3)) {
      // swiftlint:disable:previous line_length
      return nil
    }
    let section = section - 3
    var line = self.departures?.lines[safe: section] ?? "?#!"
    if App.filterFavoritesLines {
      line = self.filteredLines[section]
    }
    let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
    guard let headerCell = dequeuedCell as? DeparturesHeaderTableViewCell else {
      return UIView()
    }

    let color = LineColorManager.color(for: line,
                                       operator: self.stop?.lines[line] ?? .tpg)
    let headerCellAction = #selector(self.toggleFavoritesLines(button:))

    if line.count == 2 && line.first == "N" {
      line = Text.noctambus(line)
    }
    headerCell.titleLabel.text = line
    headerCell.titleLabel.textColor = App.darkMode ? color : color.contrast
    headerCell.titleRoundedView.backgroundColor = App.darkMode ?
      App.cellBackgroundColor.lighten(by: 0.1) : color

    if self.stop?.lines[line] == .tac {
      headerCell.subtitleLabel.isHidden = false
      headerCell.subtitleLabel.text = Text.tacNetwork
      headerCell.subtitleLabel.textColor = App.darkMode ? .white : color
    } else {
      headerCell.subtitleLabel.isHidden = true
    }

    headerCell.accessibilityLabel = Text.departuresFor(line: line)
    headerCell.favoriteButton.setImage(App.favoritesLines.contains(line) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "starEmpty"),
                                       for: .normal)
    headerCell.favoriteButton.tintColor = color
    headerCell.favoriteButton.tag = section
    headerCell.favoriteButton.addTarget(self,
                                        action: headerCellAction,
                                        for: UIControl.Event.touchUpInside)

    return headerCell
  }

  @objc func toggleFavoritesLines(button: UIButton) {
    let section = button.tag
    var line = self.departures?.lines[safe: section] ?? "?#!"
    if App.filterFavoritesLines {
      line = self.filteredLines[section]
    }
    if let index = App.favoritesLines.index(of: line) {
      App.favoritesLines.remove(at: index)
    } else {
      App.favoritesLines.append(line)
    }
    self.tableView.reloadData()
  }

  func tableView(_ tableView: UITableView,
                 heightForHeaderInSection section: Int) -> CGFloat {
    if self.requestStatus == .loading {
      return CGFloat.leastNonzeroMagnitude
    } else if self.requestStatus == any(of: .error, .noResults) {
      return CGFloat.leastNonzeroMagnitude
    } else if section == any(of: 0, 1, 2) {
      return CGFloat.leastNonzeroMagnitude
    } else if #available(iOS 12.0, *),
      ((self.requestStatus == any(of: .error, .noResults) && section == 1) ||
        (section == ((App.filterFavoritesLines ? self.filteredLines : self.departures?.lines ?? []).count) + 3)) {
      // swiftlint:disable:previous line_length
      return CGFloat.leastNonzeroMagnitude
    }
    return 44
  }

  func tableView(_ tableView: UITableView,
                 heightForFooterInSection section: Int) -> CGFloat {
    if self.requestStatus == .loading {
      return 44
    } else if self.requestStatus == any(of: .error, .noResults) {
      return CGFloat.leastNonzeroMagnitude
    } else if section == any(of: 0, 1, 2) {
      return CGFloat.leastNonzeroMagnitude
    } else if #available(iOS 12.0, *),
      ((self.requestStatus == any(of: .error, .noResults) && section == 1) ||
        (section == ((App.filterFavoritesLines ? self.filteredLines : self.departures?.lines ?? []).count) + 3)) {
      // swiftlint:disable:previous line_length
      return CGFloat.leastNonzeroMagnitude
    }
    let section = section - 3
    var line = self.departures?.lines[safe: section] ?? "?#!"
    if App.filterFavoritesLines {
      line = self.filteredLines[section]
    }
    let count = departures!.departures.filter({$0.line.code == line}).count
    if count > 5 {
      return 88
    } else {
      return 44
    }
  }

  func tableView(_ tableView: UITableView,
                 canEditRowAt indexPath: IndexPath) -> Bool {
    return self.requestStatus != .loading &&
      self.requestStatus != .error &&
      self.requestStatus != .noResults &&
      !(indexPath.section == any(of: 0, 1, 2))
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_ tableView: UITableView,
                 editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    // swiftlint:disable:previous line_length
    if indexPath.section == any(of: 0, 1, 2) {
      return []
    }
    var departuree: Departure?
    let section = indexPath.section - 3
    if App.filterFavoritesLines {
      departuree = departures?.departures.filter({
        $0.line.code == (self.filteredLines[section])
      })[indexPath.row]
    } else {
      departuree = departures?.departures.filter({
        $0.line.code == (self.departures?.lines[section] ?? "")
      })[indexPath.row]
    }

    guard var departure = departuree else { return [] }

    let smartNotificationActivated = (
      !self.noInternet &&
      App.smartReminders &&
      departure.code != -1
      && stop?.code != nil)

    let reminderAction = UITableViewRowAction(style: .normal,
                                              title: Text.reminder) { (_, _) in
      App.log("Departures: Reminder")
      departure.calculateLeftTime()
      let leftTime = Int(departure.leftTime) ?? 0

      let alertTitle = smartNotificationActivated ?
        Text.smartReminder : Text.reminder
      let alertMessage = Text.reminderMessage(stopName: self.stop?.name ?? "??",
                                              leftTime: "\(leftTime)")
      var alertController = UIAlertController(title: alertTitle,
                                              message: alertMessage,
                                              preferredStyle: .alert)
      if departure.leftTime == "0" || leftTime < 0 {
        alertController.title = Text.busIsComming
        alertController.message = Text.cantSetATimer
      } else {
        let departureTimeAction = UIAlertAction(title: Text.atDepartureTime,
                                                style: .default) { _ in
          self.setAlert(with: 0, departure: departure)
        }
        alertController.addAction(departureTimeAction)

        if leftTime > 5 {
          let fiveMinutesBeforeAction = UIAlertAction(title: Text.fiveMinutesBefore,
                                                      style: .default) { _ in
            self.setAlert(with: 5, departure: departure)
          }
          alertController.addAction(fiveMinutesBeforeAction)
        }
        if leftTime > 10 {
          let tenMinutesBeforeAction = UIAlertAction(title: Text.tenMinutesBefore,
                                                     style: .default) { _ in
            self.setAlert(with: 10, departure: departure)
          }
          alertController.addAction(tenMinutesBeforeAction)
        }

        let otherAction = UIAlertAction(title: Text.other, style: .default) { _ in
          alertController.dismiss(animated: true, completion: nil)
          alertController = UIAlertController(title: Text.reminder,
                                              message: Text.whenReminder,
                                              preferredStyle: .alert)

          alertController.addTextField { textField in
            textField.placeholder = Text.numberMinutesBeforeDepartures
            textField.keyboardType = .numberPad
            textField.keyboardAppearance = App.darkMode ? .dark : .light
          }

          let okAction = UIAlertAction(title: Text.ok,
                                       style: .default) { _ in
            guard let text = alertController.textFields?[0].text else { return }
            guard let remainingTime = Int(text) else { return }
            self.setAlert(with: remainingTime, departure: departure)
          }
          alertController.addAction(okAction)

          let cancelAction = UIAlertAction(title: Text.cancel,
                                           style: .destructive) { _ in }
          alertController.addAction(cancelAction)

          self.present(alertController, animated: true, completion: nil)
        }

        alertController.addAction(otherAction)
      }

      let cancelAction = UIAlertAction(title: Text.cancel,
                                       style: .destructive) { _ in }
      alertController.addAction(cancelAction)

      self.present(alertController, animated: true, completion: nil)
    }
    if App.darkMode {
      reminderAction.backgroundColor = .black
    } else {
      reminderAction.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
    }

    var wifi = true
    if departure.wifi == false {
      wifi = false
    }
    if #available(iOS 11.0, *) {} else {
      wifi = false
    }
    if !wifi {
      return [reminderAction]
    } else {
      let wifiAction = UITableViewRowAction(style: .normal,
                                            title: Text.wifi) { (_, _) in
        self.connectToWifi()
      }
      if App.darkMode {
        wifiAction.backgroundColor = .black
      } else {
        wifiAction.backgroundColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.5333333333, alpha: 1)
      }
      return [reminderAction, wifiAction]
    }

  }

  func setAlert(with timeBefore: Int,
                departure: Departure,
                forceDisableSmartReminders: Bool = false) {
    var departure = departure
    departure.calculateLeftTime()
    guard let departureDate = departure.dateCompenents?.date else { return }
    let date = departureDate.addingTimeInterval(TimeInterval(timeBefore * -60))
    let components = Calendar.current.dateComponents([
      .hour,
      .minute,
      .day,
      .month,
      .year], from: date)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) { (accepted, _) in
        if !accepted {
          print("Notification access denied.")
        }
      }
    } else {
      let type: UIUserNotificationType = [UIUserNotificationType.badge,
                                          UIUserNotificationType.alert,
                                          UIUserNotificationType.sound]
      let setting = UIUserNotificationSettings(types: type, categories: nil)
      UIApplication.shared.registerUserNotificationSettings(setting)
    }

    UIApplication.shared.registerForRemoteNotifications()

    var localisations = stop?.localisations ?? []
    for (index, localisation) in localisations.enumerated() {
      localisations[index].destinations = localisation.destinations.filter({
        $0.line == departure.line.code &&
          $0.destination == departure.line.destination
      })
    }
    localisations = localisations.filter { (localisation) -> Bool in
      !localisation.destinations.isEmpty
    }

    if !self.noInternet,
      App.smartReminders,
      !forceDisableSmartReminders,
      departure.code != -1,
      let stopCode = stop?.code {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      var parameters: Parameters = [
        "departureCode": departure.code,
        "title": timeBefore == 0 ?
          Text.busIsCommingNow : Text.minutesLeft(timeBefore),
        "text": Text.take(line: departure.line.code,
                          to: departure.line.destination),
        "line": departure.line.code,
        "reminderTimeBeforeDeparture": timeBefore,
        "stopCode": stopCode,
        "estimatedArrivalTime": formatter.string(from:
          Calendar.current.date(from: departure.dateCompenents!)!),
        "sandbox": false
      ]
      if let location = localisations[safe: 0]?.location {
        parameters["x"] = location.coordinate.latitude
        parameters["y"] = location.coordinate.longitude
        parameters["stopName"] = stop?.name ?? ""
      } else {
        parameters["x"] = stop?.location.coordinate.latitude ?? 0
        parameters["y"] = stop?.location.coordinate.longitude ?? 0
        parameters["stopName"] = stop?.name ?? ""
      }
      #if DEBUG
      parameters["sandbox"] = true
      #endif
      Alamofire
        .request(URL.smartReminders,
                        method: .post,
                        parameters: parameters)
        .responseString(completionHandler: { (response) in
        if let string = response.result.value, string == "1" {
          let alertMessage = Text.notificationWillBeSend(minutes: timeBefore)
          let alertController = UIAlertController(title: Text.youWillBeReminded,
                                                  message: alertMessage,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
          self.present(alertController, animated: true, completion: nil)
        } else if let string = response.result.value, string == "0" {
          let alertController = UIAlertController(title: Text.duplicateReminder,
                                                  message: Text.alreadySheduled,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
          self.present(alertController, animated: true, completion: nil)
        } else {
          let alertMessage = Text.cantAddSmartReminder
          let alertController = UIAlertController(title: Text.error,
                                                  message: alertMessage,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: Text.tryAgain,
                                                  style: .default,
                                                  handler: { (_) in
            self.setAlert(with: timeBefore,
                          departure: departure,
                          forceDisableSmartReminders: false)
          }))
          let tryAgainText = Text.tryAgainWithoutSmartRemiders
          alertController.addAction(UIAlertAction(title: tryAgainText,
                                                  style: .default,
                                                  handler: { (_) in
            self.setAlert(with: timeBefore,
                          departure: departure,
                          forceDisableSmartReminders: true)
          }))
          alertController.addAction(UIAlertAction(title: "Cancel".localized,
                                                  style: .cancel,
                                                  handler: nil))
          self.present(alertController,
                       animated: true,
                       completion: nil)
        }
      })
    } else {
      if #available(iOS 10.0, *) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: false)
        let content = UNMutableNotificationContent()

        content.title = timeBefore == 0 ?
          Text.busIsCommingNow : Text.minutesLeft(timeBefore)
        content.body = Text.take(line: departure.line.code,
                                 to: departure.line.destination) + Text.pushToShowMap
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "departureNotification"

        if let location = localisations[safe: 0]?.location {
          content.userInfo = [
            "x": location.coordinate.latitude,
            "y": location.coordinate.longitude,
            "stopName": stop?.name ?? ""
          ]
        } else {
          content.userInfo = [
            "x": stop?.location.coordinate.latitude ?? 0,
            "y": stop?.location.coordinate.longitude ?? 0,
            "stopName": stop?.name ?? ""
          ]
        }
        let notificationIdentifier = "departureNotification-\(String.random(30))"
        let request = UNNotificationRequest(identifier: notificationIdentifier,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) {(error) in
          if let error = error {
            print("Uh oh! We had an error: \(error)")
            let alertController = UIAlertController(title: Text.error,
                                                    message: Text.sorryError,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Text.ok,
                                                    style: .default,
                                                    handler: nil))
            alertController.addAction(UIAlertAction(title: Text.sendMail,
                                                    style: .default,
                                                    handler: { (_) in
              let mailComposerVC = MFMailComposeViewController()
              mailComposerVC.mailComposeDelegate = self

              mailComposerVC.setToRecipients(["support@asmartcode.com"])
              mailComposerVC.setSubject("tpg offline - Bug report")
              mailComposerVC.setMessageBody("\(error.localizedDescription)",
                isHTML: false)

              if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC, animated: true, completion: nil)
              }
            }))

            self.present(alertController, animated: true, completion: nil)
          } else {
            let alertMessage = Text.notificationWillBeSend(minutes: timeBefore)
            let alertController = UIAlertController(title: Text.youWillBeReminded,
                                                    message: alertMessage,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Text.ok,
                                                    style: .default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
          }
        }
      } else {
        let notification = UILocalNotification()
        notification.fireDate = date
        if timeBefore == 0 {
          notification.alertBody = Text.take(line: departure.line.code,
                                             to: departure.line.destination)
        } else {
          notification.alertBody = Text.take(line: departure.line.code,
                                             to: departure.line.destination,
                                             in: timeBefore)
        }
        notification.identifier = "departureNotification-\(String.random(30))"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
      }
    }
  }

  @IBAction func connectToWifi() {
    #if !arch(i386) && !arch(x86_64)
    if #available(iOS 11.0, *) {
      let configuration = NEHotspotConfiguration(ssid: "tpg-freeWiFi")
      configuration.joinOnce = false
      NEHotspotConfigurationManager.shared.apply(configuration,
                                                 completionHandler: { (error) in
        print(error ?? "Unknow error")
      })
    } else {
      print("How did you ended here ?")
    }
    #endif
  }
}

extension DeparturesViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint)
    -> UIViewController? {

    guard let indexPath = tableView.indexPathForRow(at: location) else {
      return nil
    }

    guard let cell = tableView.cellForRow(at: indexPath)
      as? DeparturesTableViewCell else { return nil }

    let viewControllerId = "detailDeparturesViewController"
    guard let detailVC =
      storyboard?.instantiateViewController(withIdentifier: viewControllerId)
        as? DetailDeparturesViewController else { return nil }

    guard let departure = cell.departure else {
      return nil
    }

    if self.stop?.lines[departure.line.code] == .tac {
      return nil
    }

    detailVC.color = LineColorManager.color(for: departure.line.code)
    detailVC.departure = cell.departure
    detailVC.stop = self.stop
    previewingContext.sourceRect = cell.frame
    return detailVC
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
}

extension DeparturesViewController: StopSelectionDelegate {
  func stopSelected(_ newStop: Stop) {
    self.stop = newStop
  }
}

extension DeparturesViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}

extension DeparturesViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView,
               annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }

  func mapView(_ mapView: MGLMapView,
               calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
    // Instantiate and return our custom callout view.
    return CustomCalloutView(representedObject: annotation)
  }
}
