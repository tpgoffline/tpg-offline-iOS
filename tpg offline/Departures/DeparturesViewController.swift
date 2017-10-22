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

class DeparturesViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!

    var stop: Stop?
    var departures: DeparturesGroup?
    var showMoreLines: [String] = []
    var noInternet = false
    var requestStatus: RequestStatus = .loading {
        didSet {
            self.tableView.allowsSelection = requestStatus == .ok
            self.tableView.reloadData()
        }
    }

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.stop == nil {
            self.stop = App.stops[0]
        }

        navigationItem.title = stop?.name
        refreshDepatures()
        self.mapView.isHidden = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62

        configureTabBarItems()

        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(stop!.location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = stop!.location.coordinate
        annotation.title = stop?.name
        mapView.addAnnotation(annotation)

        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refreshDepatures), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        if self.view.traitCollection.verticalSizeClass == .compact && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
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
                            action: #selector(self.setFavorite)),
            UIBarButtonItem(image: #imageLiteral(resourceName: "pinMapNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.showMap)),
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.reload))
        ]
    }

    @objc func refreshDepatures() {
        self.departures = nil
        self.requestStatus = .loading
        self.noInternet = false
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json",
                          method: .get,
                          parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b",
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

    func loadOfflineDepartures() {
        let day = Calendar.current.dateComponents([.weekday], from: Date())
        var path: URL

        guard let dirString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first else {
            return
        }
        let dir = URL(fileURLWithPath: dirString)
        switch day.weekday! {
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
            if self.departures?.lines.count == 0 {
                self.requestStatus = .noResults
                return
            }
            self.noInternet = true
            self.tableView.reloadData()
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
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    @objc func setFavorite() {
        if let index = App.favoritesStops.index(of: stop!.appId) {
            App.favoritesStops.remove(at: index)
        } else {
            App.favoritesStops.append(stop!.appId)
        }
        configureTabBarItems()
        guard let vc = (navigationController?.viewControllers[0]
            as? StopsTableViewController) else {
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
            return (self.departures?.lines.count ?? 0) + (self.noInternet ? 1 : 0)
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.requestStatus == .loading {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath)
                as? DeparturesTableViewCell else {
                    return UITableViewCell()
            }
            return cell
        } else if self.requestStatus == .error {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "globe")
            cell.textLabel?.text = "Error".localized
            cell.detailTextLabel?.text = "You don't downloaded offline departures, and you're not connected to internet".localized
            return cell
        } else if self.requestStatus == .noResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "warningSign")
            cell.textLabel?.text = "That's all for today".localized
            cell.detailTextLabel?.text = "No more bus will come to this stop today.".localized
            return cell
        } else if self.noInternet && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "globe")
            cell.textLabel?.text = "Offline mode".localized
            cell.detailTextLabel?.text = "You are using timetables departures. So departures are subjects to change.".localized
            return cell
        }
        let section = indexPath.section - (self.noInternet ? 1 : 0)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath)
            as? DeparturesTableViewCell else {
                return UITableViewCell()
        }

        let departure = departures?.departures.filter({$0.line.code == (self.departures?.lines[section] ?? "")})[indexPath.row]
        cell.departure = departure!

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
        let count = departures!.departures.filter({$0.line.code == (self.departures?.lines[safe: section] ?? "")}).count
        if count > 5 {
            guard let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as? FooterDeparturesTableViewCell
                else { return nil }
            let color = App.linesColor.filter({$0.line == (departures?.lines[section] ?? "?#!")})[safe: 0]?.color ?? .white
            if showMoreLines.contains(String(section)) {
                footerCell.button.setTitle("Show less".localized, for: .normal)
            } else {
                footerCell.button.setTitle("Show more".localized, for: .normal)
            }
            footerCell.button.setTitleColor(color.contrast, for: .normal)
            footerCell.button.tag = section
            footerCell.button.addTarget(self, action: #selector(self.addRemoveFromShowMore(button:)), for: .touchUpInside)
            footerCell.button.backgroundColor = color
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

        // tableView.scrollToRow(at: IndexPath(row: 0, section: button.tag), at: .top, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.requestStatus == .loading {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
            headerCell?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            headerCell?.textLabel?.text = ""
            return headerCell
        } else if self.requestStatus == any(of: .error, .noResults) {
            return nil
        } else if self.noInternet && section == 0 {
            return nil
        }
        let section = section - (self.noInternet ? 1 : 0)
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        headerCell?.backgroundColor = App.linesColor.filter({$0.line == (departures?.lines[section] ?? "?#!".localized)})[safe: 0]?.color ?? .white
        headerCell?.textLabel?.text = String(format: "Line %@".localized, "\(departures?.lines[section] ?? "?#!".localized)")
        headerCell?.textLabel?.textColor = headerCell?.backgroundColor?.contrast

        return headerCell
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
        let count = departures!.departures.filter({$0.line.code == (self.departures?.lines[section] ?? "")}).count
        if count > 5 {
            return 88
        } else {
            return 44
        }
    }
}
