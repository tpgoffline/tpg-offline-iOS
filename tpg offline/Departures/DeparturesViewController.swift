//
//  DeparturesViewController.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 10/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import Crashlytics
import UserNotifications
import MessageUI
#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

class DeparturesViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!

    var stop: Stop? {
        didSet {
            guard let stop = stop else { return }
            App.log("Departures: Selected \(stop.code)")
            Answers.logCustomEvent(withName: "Show departures",
                                   customAttributes: ["appId": stop.code])

            navigationItem.title = stop.name
            navigationItem.accessibilityTraits = UIAccessibilityTraitNone
            refreshDepatures()

            configureTabBarItems()

            guard let mapView = self.mapView else { return }
            mapView.removeAnnotations(mapView.annotations)

            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(stop.location.coordinate,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)

            if !stop.localisations.isEmpty {
                for localisation in stop.localisations {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = localisation.location.coordinate
                    annotation.title = stop.name
                    var subtitle = ""
                    for destination in localisation.destinations {
                        subtitle.append(String(format: "Line %@ - %@\n", destination.line, destination.destination))
                    }
                    annotation.subtitle = subtitle
                    mapView.addAnnotation(annotation)
                }
            } else {
                let annotation = MKPointAnnotation()
                annotation.coordinate = stop.location.coordinate
                annotation.title = stop.name
                mapView.addAnnotation(annotation)
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
        } else {
            let stop = self.stop
            self.stop = nil
            self.stop = stop
        }

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }

        refreshControl.addTarget(self, action: #selector(refreshDepatures), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        self.mapView.isHidden = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62

        if self.view.traitCollection.verticalSizeClass == .compact && UIDevice.current.userInterfaceIdiom == .phone {
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

        ColorModeManager.shared.addColorModeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureTabBarItems() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: App.filterFavoritesLines ? #imageLiteral(resourceName: "filter") : #imageLiteral(resourceName: "filterEmpty"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.toggleFilterFavoritesLines),
                            accessbilityLabel: "Filter favorites lines".localized),
            UIBarButtonItem(image: App.favoritesStops.contains(stop!.appId) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "starEmpty"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.setFavorite),
                            accessbilityLabel: App.favoritesStops.contains(stop!.appId) ?
                                "Unmark this stop as favorite".localized :
                                "Mark this stop as favorite".localized),
            UIBarButtonItem(image: #imageLiteral(resourceName: "pinMapNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.showMap),
                            accessbilityLabel: "Show map".localized),
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.reload),
                            accessbilityLabel: "Reload departures".localized)
        ]
    }

    @objc func refreshDepatures() {
        self.departures = nil
        self.requestStatus = .loading
        self.noInternet = false
        Alamofire.request("https://tpgoffline-apns.alwaysdata.net/api/departures/\(stop!.code)", method: .get)
            .responseData { (response) in
                if let data = response.result.value {
                    var options = DeparturesOptions()
                    options.networkStatus = .online
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.userInfo = [ DeparturesOptions.key: options ]
                    do {
                        let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
                        self.departures = json
                        self.filteredLines = json.lines.filter({ App.favoritesLines.contains($0) })
                        self.requestStatus = .ok
                    } catch {
                        self.loadOfflineDepartures()
                        return
                    }

                    if self.departures?.lines.count == 0 {
                        self.requestStatus = .noResults
                    }
                } else {
                    self.loadOfflineDepartures()
                }
                self.refreshControl.endRefreshing()
        }
    }

    @objc func toggleFilterFavoritesLines() {
        App.filterFavoritesLines = !(App.filterFavoritesLines)
        self.configureTabBarItems()
        showMoreLines = []
        self.filteredLines = self.departures?.lines.filter({ App.favoritesLines.contains($0) }) ?? []
        self.tableView.reloadData()
    }

    func loadOfflineDepartures() {
        let day = Calendar.current.dateComponents([.weekday], from: Date())
        var path: URL

        guard let dirString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first else {
            return
        }
        let dir = URL(fileURLWithPath: dirString)
        switch day.weekday! {
        case 6:
            path = dir.appendingPathComponent(self.stop!.code + "VEN.json")
        case 7:
            path = dir.appendingPathComponent(self.stop!.code + "SAM.json")
        case 1:
            path = dir.appendingPathComponent(self.stop!.code + "DIM.json")
        default:
            path = dir.appendingPathComponent(self.stop!.code + "LUN.json")
        }

        do {
            let data = try Data(contentsOf: path)
            var options = DeparturesOptions()
            options.networkStatus = .offline
            let jsonDecoder = JSONDecoder()
            jsonDecoder.userInfo = [ DeparturesOptions.key: options ]
            let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
            self.departures = json
            self.departures?.departures.sort(by: { (departure1, departure2) -> Bool in
                let leftTime1: Int = Int(departure1.leftTime)!
                let leftTime2: Int = Int(departure2.leftTime)!
                return leftTime1 < leftTime2
            })
            self.filteredLines = self.departures?.lines.filter({ App.favoritesLines.contains($0) }) ?? []
            if self.departures?.lines.count == 0 {
                self.requestStatus = .noResults
                return
            }
            self.noInternet = true
            self.requestStatus = .ok
        } catch {
            self.requestStatus = .error
            return
        }
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
        self.tableView.backgroundColor = App.darkMode ? .black : .groupTableViewBackground
        self.tableView.separatorColor = App.separatorColor
        self.tableView.reloadData()
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeparturesDetail" {
            guard let destinationViewController = segue.destination as? DetailDeparturesViewController else {
                return
            }
            let indexPath = tableView.indexPathForSelectedRow!
            guard let row = tableView.cellForRow(at: indexPath) as? DeparturesTableViewCell else {
                return
            }
            destinationViewController.color = App.color(for: row.departure!.line.code)
            destinationViewController.departure = row.departure
            destinationViewController.stop = self.stop
            App.log("Departures: Select \(row.departure?.line.code ?? "") - \(row.departure?.line.destination ?? "") - \(row.departure?.timestamp ?? "")") // swiftlint:disable:this line_length
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if segue.identifier == "showConnectionsMap" {
            guard let destinationViewController = segue.destination as? ConnectionsMapViewController else {
                return
            }
            destinationViewController.stopCode = self.stop?.code ?? ""
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
            as? UINavigationController)?.topViewController as? StopsTableViewController) else {
                return
        }
        vc.tableView.reloadData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.view.traitCollection.verticalSizeClass == .compact && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
    }
}

extension DeparturesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.requestStatus == .loading {
            return 1
        } else if self.requestStatus == any(of: .error, .noResults) {
            return 1
        } else {
            if App.filterFavoritesLines {
                return (self.filteredLines.count) + 3
            } else {
                return (self.departures?.lines.count ?? 0) + 3
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.requestStatus == .loading {
            return 5
        } else if self.requestStatus == any(of: .error, .noResults) {
            return 1
        }
        switch section {
        case 0:
            return self.noInternet ? 1 : 0
        case 1:
            return App.filterFavoritesLines ? 1 : 0
        case 2:
            return (self.stop?.connectionsMap ?? false) ? 1 : 0
        default:
            let section = section - 3
            if App.filterFavoritesLines {
                if let count = departures?.departures.filter({$0.line.code == (self.filteredLines[section])}).count {
                    if count > 5 && !(showMoreLines.contains(String(section))) {
                        return 4
                    } else {
                        return count
                    }
                } else {
                    return 0
                }
            } else {
                if let count = departures?.departures.filter({$0.line.code == (self.departures?.lines[section] ?? "")}).count {
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.requestStatus == .loading {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath)
                as? DeparturesTableViewCell else {
                    return UITableViewCell()
            }
            cell.departure = nil
            return cell
        } else if self.requestStatus == .error {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "globe").maskWith(color: App.textColor)
            cell.textLabel?.text = "Error".localized
            cell.detailTextLabel?.text = "You don't downloaded offline departures, and you're not connected to internet".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.textColor = App.textColor
            cell.backgroundColor = App.cellBackgroundColor
            return cell
        } else if self.requestStatus == .noResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "warningSign").maskWith(color: App.textColor)
            cell.textLabel?.text = "That's all for today".localized
            cell.detailTextLabel?.text = "No more bus will come to this stop today.".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.textColor = App.textColor
            cell.backgroundColor = App.cellBackgroundColor
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "connectionCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "transfer").maskWith(color: App.textColor)
            cell.textLabel?.text = "Connections map".localized
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "globe").maskWith(color: App.textColor)
            cell.textLabel?.text = "Offline mode".localized
            cell.detailTextLabel?.text = "You are using timetables departures. So departures are subjects to change.".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.textColor = App.textColor
            cell.backgroundColor = App.cellBackgroundColor
            return cell
        }
        let section = indexPath.section - 3
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath)
            as? DeparturesTableViewCell else {
                return UITableViewCell()
        }

        let departure: Departure?
        if App.filterFavoritesLines {
            departure = departures?.departures.filter({$0.line.code == (self.filteredLines[section])})[indexPath.row]
        } else {
            departure = departures?.departures.filter({$0.line.code == (self.departures?.lines[section] ?? "")})[indexPath.row]
        }
        cell.departure = departure
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.requestStatus == .loading {
            return nil
        } else if self.requestStatus == any(of: .error, .noResults) {
            return nil
        } else if section == any(of: 0, 1, 2) {
            return nil
        }
        let section = section - 3
        var line = self.departures?.lines[safe: section] ?? "?#!"
        if App.filterFavoritesLines {
            line = self.filteredLines[section]
        }
        let count = departures!.departures.filter({$0.line.code == line}).count
        if count > 5 {
            guard let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as? FooterDeparturesTableViewCell
                else { return nil }
            let color = App.color(for: line)
            if showMoreLines.contains(String(section)) {
                footerCell.button.setTitle("Show less".localized, for: .normal)
            } else {
                footerCell.button.setTitle("Show more".localized, for: .normal)
            }
            footerCell.button.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            footerCell.button.tag = section
            footerCell.button.addTarget(self, action: #selector(self.addRemoveFromShowMore(button:)), for: .touchUpInside)
            footerCell.button.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.requestStatus == .loading {
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? DeparturesHeaderTableViewCell else {
                return UIView()
            }
            headerCell.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            headerCell.titleLabel?.text = ""
            return headerCell
        } else if self.requestStatus == any(of: .error, .noResults) {
            return nil
        } else if section == any(of: 0, 1, 2) {
            return nil
        }
        let section = section - 3
        var line = self.departures?.lines[safe: section] ?? "?#!"
        if App.filterFavoritesLines {
            line = self.filteredLines[section]
        }
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? DeparturesHeaderTableViewCell else {
            return UIView()
        }
        let color = App.color(for: line)
        headerCell.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
        if line.count == 2 && line.first == "N" {
            line = "Noctambus \(line.last ?? Character(""))"
        }
        headerCell.titleLabel?.text = String(format: "Line %@".localized, "\(line)")
        headerCell.titleLabel?.textColor = App.darkMode ? color : color.contrast

        headerCell.accessibilityLabel = String(format: "Departures for the line %@".localized, "\(line)")

        headerCell.favoriteButton.setImage(App.favoritesLines.contains(line) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "starEmpty"), for: .normal)
        headerCell.favoriteButton.tintColor = App.darkMode ? color : color.contrast
        headerCell.favoriteButton.tag = section
        headerCell.favoriteButton.addTarget(self, action: #selector(self.toggleFavoritesLines(button:)), for: UIControlEvents.touchUpInside)

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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.requestStatus == .loading {
            return CGFloat.leastNonzeroMagnitude
        } else if self.requestStatus == any(of: .error, .noResults) {
            return CGFloat.leastNonzeroMagnitude
        } else if section == any(of: 0, 1, 2) {
            return CGFloat.leastNonzeroMagnitude
        }
        return 44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.requestStatus == .loading {
            return 44
        } else if self.requestStatus == any(of: .error, .noResults) {
            return CGFloat.leastNonzeroMagnitude
        } else if section == any(of: 0, 1, 2) {
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.requestStatus != .loading &&
            self.requestStatus != .error &&
            self.requestStatus != .noResults &&
            !(indexPath.section == any(of: 0, 1, 2))
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == any(of: 0, 1, 2) {
            return []
        }
        var departuree: Departure?
        let section = indexPath.section - 3
        if App.filterFavoritesLines {
            departuree = departures?.departures.filter({$0.line.code == (self.filteredLines[section])})[indexPath.row]
        } else {
            departuree = departures?.departures.filter({$0.line.code == (self.departures?.lines[section] ?? "")})[indexPath.row]
        }

        guard var departure = departuree else { return [] }
        let smartNotificationActivated = (!self.noInternet && App.smartReminders && (departure.code != -1) && stop?.code != nil)

        let reminderAction = UITableViewRowAction(style: .normal, title: "Reminder".localized) { (_, _) in
            App.log("Departures: Reminder")
            departure.calculateLeftTime()
            let leftTime = Int(departure.leftTime) ?? 0
            var alertController = UIAlertController(title: smartNotificationActivated ? "Smart Reminder".localized : "Reminder".localized,
                                                    message: String(format: "At %@ - In %@ minutes\nWhen do you want to be reminded?".localized, self.stop?.name ?? "??", "\(leftTime)"),
                                                    preferredStyle: .alert)
            if departure.leftTime == "0" {
                alertController.title = "Bus is comming".localized
                alertController.message = "You can't set a timer for this bus, but you should run to take it.".localized
            } else {
                let departureTimeAction = UIAlertAction(title: "At departure time".localized, style: .default) { _ in
                    self.setAlert(with: 0, departure: departure)
                }
                alertController.addAction(departureTimeAction)

                if leftTime > 5 {
                    let fiveMinutesBeforeAction = UIAlertAction(title: "5 minutes before".localized, style: .default) { _ in
                        self.setAlert(with: 5, departure: departure)
                    }
                    alertController.addAction(fiveMinutesBeforeAction)
                }
                if leftTime > 10 {
                    let tenMinutesBeforeAction = UIAlertAction(title: "10 minutes before".localized, style: .default) { _ in
                        self.setAlert(with: 10, departure: departure)
                    }
                    alertController.addAction(tenMinutesBeforeAction)
                }

                let otherAction = UIAlertAction(title: "Other".localized, style: .default) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                    alertController = UIAlertController(title: "Reminder".localized,
                                                        message: "When do you want to be reminded".localized,
                                                        preferredStyle: .alert)

                    alertController.addTextField { textField in
                        textField.placeholder = "Number of minutes before departure".localized
                        textField.keyboardType = .numberPad
                        textField.keyboardAppearance = App.darkMode ? .dark : .light
                    }

                    let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
                        guard let remainingTime = Int(alertController.textFields?[0].text ?? "#!?") else { return }
                        self.setAlert(with: remainingTime, departure: departure)
                    }
                    alertController.addAction(okAction)

                    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive) { _ in
                    }
                    alertController.addAction(cancelAction)

                    self.present(alertController, animated: true, completion: nil)
                }

                alertController.addAction(otherAction)
            }

            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive) { _ in }
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
            let wifiAction = UITableViewRowAction(style: .normal, title: "Wi-Fi".localized) { (_, _) in
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

    func setAlert(with timeBefore: Int, departure: Departure, forceDisableSmartReminders: Bool = false) {
        var departure = departure
        departure.calculateLeftTime()
        let date = departure.dateCompenents?.date?.addingTimeInterval(TimeInterval(timeBefore * -60))
        let components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: date ?? Date())

        if !self.noInternet, App.smartReminders, !forceDisableSmartReminders, departure.code != -1, let stopCode = stop?.code {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            var parameters: Parameters = [
                "device": App.apnsToken,
                "departureCode": departure.code,
                "title": timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)"),
                "text": String(format: "Take the line %@ to %@".localized,
                               "\(departure.line.code)", "\(departure.line.destination)"),
                "line": departure.line.code,
                "reminderTimeBeforeDeparture": timeBefore,
                "stopCode": stopCode,
                "estimatedArrivalTime": formatter.string(from: Calendar.current.date(from: departure.dateCompenents!)!),
                "sandbox": false
            ]
            #if DEBUG
            parameters["sandbox"] = true
            #endif
            Alamofire.request("https://tpgoffline-apns.alwaysdata.net/reminders/add", method: .post, parameters: parameters).responseString(completionHandler: { (response) in
                dump(response)
                if let string = response.result.value, string == "1" {
                    let alertController = UIAlertController(title: "You will be reminded".localized,
                                                            message: String(format: "A notification will be send %@".localized,
                                                                            (timeBefore == 0 ? "at the time of departure.".localized :
                                                                                String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else if let string = response.result.value, string == "0" {
                    let alertController = UIAlertController(title: "Duplicated reminder".localized,
                                                            message: "We already sheduled a reminder with these parameters.".localized,
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Error".localized, message: "Sorry, but we were not able to add your smart notification. Do you want to try again?".localized, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Try again".localized, style: .default, handler: { (_) in
                        self.setAlert(with: timeBefore, departure: departure, forceDisableSmartReminders: false)
                    }))
                    alertController.addAction(UIAlertAction(title: "Try again without Smart Reminders".localized, style: .default, handler: { (_) in
                        self.setAlert(with: timeBefore, departure: departure, forceDisableSmartReminders: true)
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            if #available(iOS 10.0, *) {
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let content = UNMutableNotificationContent()

                content.title = timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)")
                content.body = String(format: "Take the line %@ to %@".localized,
                                      "\(departure.line.code)", "\(departure.line.destination)")
                content.sound = UNNotificationSound.default()
                content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
                let request = UNNotificationRequest(identifier: "departureNotification-\(String.random(30))", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) {(error) in
                    if let error = error {
                        print("Uh oh! We had an error: \(error)")
                        let alertController = UIAlertController(title: "An error occurred".localized,
                                                                message: "Sorry for that. Can you try again, or send an email to us if the problem persist?".localized, // swiftlint:disable:this line_length
                            preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alertController.addAction(UIAlertAction(title: "Send email", style: .default, handler: { (_) in
                            let mailComposerVC = MFMailComposeViewController()
                            mailComposerVC.mailComposeDelegate = self

                            mailComposerVC.setToRecipients(["support@asmartcode.com"])
                            mailComposerVC.setSubject("tpg offline - Bug report")
                            mailComposerVC.setMessageBody("\(error.localizedDescription)", isHTML: false)

                            if MFMailComposeViewController.canSendMail() {
                                self.present(mailComposerVC, animated: true, completion: nil)
                            }
                        }))

                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "You will be reminded".localized,
                                                                message: String(format: "A notification will be send %@".localized,
                                                                                (timeBefore == 0 ? "at the time of departure.".localized :
                                                                                    String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                let notification = UILocalNotification()
                notification.fireDate = date ?? Date()
                if timeBefore == 0 {
                    notification.alertBody = String(format: "Take the line %@ to %@ now".localized,
                                                    "\(departure.line.code)", "\(departure.line.destination)")
                } else {
                    notification.alertBody = String(format: "Take the line %@ to %@ in %@ minutes".localized,
                                                    "\(departure.line.code)", "\(departure.line.destination)",
                        "\(timeBefore)")
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
            NEHotspotConfigurationManager.shared.apply(configuration, completionHandler: { (error) in
                print(error ?? "")
            })
        } else {
            print("How did you ended here ?")
        }
        #endif
    }
}

extension DeparturesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? DeparturesTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailDeparturesViewController") as?
            DetailDeparturesViewController
            else { return nil }

        guard let departure = row.departure else {
            return nil
        }

        detailVC.color = App.color(for: departure.line.code)
        detailVC.departure = row.departure
        detailVC.stop = self.stop
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

extension DeparturesViewController: StopSelectionDelegate {
    func stopSelected(_ newStop: Stop) {
        self.stop = newStop
    }
}

extension DeparturesViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
