//
//  RouteResultsTableViewController.swift
//  tpg offline
//
//  Created by Remy on 10/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

class RouteResultsTableViewController: UITableViewController {

    var route: Route? = nil {
        didSet {
            guard let route = self.route else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            App.log("Routes: Search with D: \(route.from?.appId ?? 0)/\(route.from?.code ?? "") - A: \(route.to?.appId ?? 0)/\(route.to?.code ?? "") - H: \(dateFormatter.string(from: route.date)) - IAT: \(String(describing: route.arrivalTime.hashValue))") // swiftlint:disable:this line_length

            Answers.logCustomEvent(withName: "Search route",
                                   customAttributes: ["departure": route.from?.code ?? "XXXX",
                                                      "arrival": route.to?.code ?? "XXXX",
                                                      "route": "\(route.from?.code ?? "XXXX")-\(route.to?.code ?? "XXXX")"])

            configureTabBarItems()
            refresh()
        }
    }
    var results: RouteResults? = nil {
        didSet {
            self.tableView.allowsSelection = self.results != nil
            self.tableView.reloadData()
        }
    }
    var routeStops: [String: RouteStop] = [:]

    var requestStatus: RequestStatus = .loading {
        didSet {
            if requestStatus == .noResults {
                let alertController = UIAlertController(title: "No results".localized,
                                                        message: "Sorry, but no results was found. Please try with other parameters.".localized,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else if requestStatus == .error {
                let alertController = UIAlertController(title: "Error".localized,
                                                        message: "Sorry, there is an error. Are you sure your are connected to internet ?".localized,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Results".localized
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 96

        self.refreshControl = UIRefreshControl()

        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        tableView.allowsSelection = false
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(self.refreshControl!)
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        ColorModeManager.shared.addColorModeDelegate(self)

        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }

    func configureTabBarItems() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: App.favoritesRoutes.contains(where: { $0 == self.route }) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "starEmpty"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.setFavorite)),
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.refresh))
        ]
    }

    @objc func setFavorite() {
        guard let route = self.route else { return }
        if let route = App.favoritesRoutes.index(of: route) {
            App.favoritesRoutes.remove(at: route)
        } else {
            App.favoritesRoutes.append(route)
        }
        configureTabBarItems()
        guard let vc = ((splitViewController?.viewControllers.first
            as? UINavigationController)?.topViewController as? RoutesTableViewController) else {
                return
        }
        vc.tableView.reloadData()
    }

    @objc func refresh() {
        if (App.tpgofflineRoutesAlgorithm) {
            let alertView = UIAlertController(title: "tpg offline Routes Algorithm", message: "", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertView, animated: true, completion: nil)
            do {
                let data: Data
                if let dataA = UserDefaults.standard.data(forKey: "routes.json") {
                    data = dataA
                } else {
                    do {
                        data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "routes", ofType: "json")!))
                    } catch {
                        print("Can't load routes.json")
                        abort()
                    }
                }
                let decoder = JSONDecoder()
                self.routeStops = try decoder.decode([String: RouteStop].self, from: data)

            } catch {
                print("Can't load routes")
            }
        } else {
            guard let route = self.route else { return }
            self.requestStatus = .loading
            self.results = nil
            var parameters: [String: Any] = [:]
            parameters["from"] = route.from?.sbbId
            parameters["to"] = route.to?.sbbId
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            parameters["date"] = dateFormatter.string(from: route.date)
            dateFormatter.dateFormat = "HH:mm"
            parameters["time"] = dateFormatter.string(from: route.date)
            parameters["isArrivalTime"] = String(describing: route.arrivalTime.hashValue)
            parameters["fields"] = [
                "connections/duration",
                "connections/from/station/id",
                "connections/from/station/name",
                "connections/from/station/coordinate",
                "connections/from/departureTimestamp",
                "connections/to/station/id",
                "connections/to/station/name",
                "connections/to/station/coordinate",
                "connections/to/arrivalTimestamp",
                "connections/sections/walk",
                "connections/sections/journey/number",
                "connections/sections/journey/operator",
                "connections/sections/journey/category",
                "connections/sections/journey/to",
                "connections/sections/journey/passList",
                "connections/sections/departure/station/name",
                "connections/sections/departure/station/id",
                "connections/sections/departure/station/coordinate",
                "connections/sections/departure/departureTimestamp",
                "connections/sections/arrival/station/name",
                "connections/sections/arrival/station/id",
                "connections/sections/arrival/station/coordinate",
                "connections/sections/arrival/arrivalTimestamp"
            ]
            parameters["limit"] = 6

            Alamofire.request("https://transport.opendata.ch/v1/connections", method: .get, parameters: parameters).responseData { (response) in
                if let data = response.result.value {
                    do {
                        let results = try JSONDecoder().decode(RouteResults.self, from: data)
                        self.requestStatus = results.connections.count == 0 ? .noResults : .ok
                        self.results = results
                    } catch let error as NSError {
                        dump(error)
                        self.requestStatus = .error
                    }
                } else {
                    self.requestStatus = .error
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.requestStatus == any(of: .ok, .loading) {
            return self.results?.connections.count ?? (self.route == nil ? 0 : 6)
        } else { return 0 }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "routeResultCell", for: indexPath)
            as? RouteResultsTableViewCell else {
                return UITableViewCell()
        }

        if self.requestStatus == .ok {
            cell.connection = self.results?.connections[indexPath.row]
        } else {
            cell.connection = nil
        }

        return cell
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRouteDetail" {
            guard let destinationViewController = segue.destination as? RouteResultsDetailTableViewController else {
                return
            }
            App.log("Routes: Selected \(tableView.indexPathForSelectedRow!.row) row")
            guard let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? RouteResultsTableViewCell else {
                return
            }
            guard let connection = cell.connection else {
                return
            }
            destinationViewController.connection = connection
        }
    }

}

extension RouteResultsTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? RouteResultsTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "routeResultsDetailTableViewController") as?
            RouteResultsDetailTableViewController
            else { return nil }

        detailVC.connection = row.connection
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        show(viewControllerToCommit, sender: self)

    }
}

extension RouteResultsTableViewController: RouteSelectionDelegate {
    func routeSelected(_ newRoute: Route) {
        self.route = newRoute
    }
}
