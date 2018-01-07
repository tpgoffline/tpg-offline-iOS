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
                            accessbilityLabel: "Reload departures".localized),
            UIBarButtonItem(image: App.filterFavoritesLines ? #imageLiteral(resourceName: "filter") : #imageLiteral(resourceName: "filterEmpty"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.toggleFilterFavoritesLines),
                            accessbilityLabel: "Filter favorites lines".localized)
        ]
    }

    @objc func refreshDepatures() {
        self.departures = nil
        self.requestStatus = .loading
        self.noInternet = false
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json",
                          method: .get,
                          parameters: ["key": API.tpg,
                                       "stopCode": stop!.code])
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
        UIView.animate(withDuration: 0.5) {
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
            App.log( "Departures: Select \(row.departure?.line.code ?? "") - \(row.departure?.line.destination ?? "") - \(row.departure?.timestamp ?? "")") // swiftlint:disable:this line_length
            tableView.deselectRow(at: indexPath, animated: true)
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
                return (self.filteredLines.count) + (self.noInternet ? 1 : 0)
            } else {
                return (self.departures?.lines.count ?? 0) + (self.noInternet ? 1 : 0)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.requestStatus == .loading {
            return 5
        } else if self.requestStatus == any(of: .error, .noResults) {
            return 1
        } else if self.noInternet && section == 0 {
            return 1
        }
        let section = section - (self.noInternet ? 1 : 0)
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
        } else if self.noInternet && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "globe").maskWith(color: App.textColor)
            cell.textLabel?.text = "Offline mode".localized
            cell.detailTextLabel?.text = "You are using timetables departures. So departures are subjects to change.".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.textColor = App.textColor
            cell.backgroundColor = App.cellBackgroundColor
            return cell
        }
        let section = indexPath.section - (self.noInternet ? 1 : 0)
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
        } else if self.noInternet && section == 0 {
            return nil
        }
        let section = section - (self.noInternet ? 1 : 0)
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
        } else if self.noInternet && section == 0 {
            return nil
        }
        let section = section - (self.noInternet ? 1 : 0)
        var line = self.departures?.lines[safe: section] ?? "?#!"
        if App.filterFavoritesLines {
            line = self.filteredLines[section]
        }
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? DeparturesHeaderTableViewCell else {
            return UIView()
        }
        let color = App.color(for: line)
        headerCell.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
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
        return 44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.requestStatus == .loading {
            return 44
        } else if self.requestStatus == any(of: .error, .noResults) {
            return 0
        } else if self.noInternet && section == 0 {
            return 0
        }
        let section = section - (self.noInternet ? 1 : 0)
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
}

extension DeparturesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? DeparturesTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailDeparturesViewController") as?
            DetailDeparturesViewController
            else { return nil }

        detailVC.color = App.color(for: row.departure!.line.code)
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
