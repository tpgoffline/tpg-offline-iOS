//
//  RouteResultsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 10/09/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
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
      App.log("Routes: Search with D: \(route.from?.appId ?? 0)/\(route.from?.code ?? "") - A: \(route.to?.appId ?? 0)/\(route.to?.code ?? "") - H: \(dateFormatter.string(from: route.date)) - IAT: \(route.arrivalTime.description)") // swiftlint:disable:this line_length

      App.logEvent("Search route",
                   attributes:
        ["departure": route.from?.code ?? "XXXX",
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

  var requestStatus: RequestStatus = .loading {
    didSet {
      if requestStatus == .noResults {
        let alertController = UIAlertController(title: Text.noResults,
                                                message: Text.noResultsFound,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.ok, style: .default) { _ in
          self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      } else if requestStatus == .error {
        let alertController = UIAlertController(title: Text.error,
                                                message: Text.errorNoInternet,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.ok, style: .default) { _ in
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
    self.tableView.rowHeight = UITableView.automaticDimension
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
    // swiftlint:disable:previous line_length
    if self.traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }
  }

  func configureTabBarItems() {
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: App.favoritesRoutes.contains(where: {
        $0 == self.route
      }) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "starEmpty"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.setFavorite)),
      UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                      style: UIBarButtonItem.Style.plain,
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
      as? UINavigationController)?.topViewController as? RoutesTableViewController)
      else {
        return
    }
    vc.tableView.reloadData()
  }

  @objc func refresh() {
    guard let route = self.route else { return }
    self.requestStatus = .loading
    self.results = nil
    var parameters: [String: Any] = [:]
    parameters["from"] = route.from?.sbbId
    parameters["to"] = route.to?.sbbId
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(identifier: "Europe/Paris")
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
    parameters["via"] = (route.via ?? []).map({ $0.sbbId })

    Alamofire.request(URL.connections,
                      method: .get,
                      parameters: parameters).responseData { (response) in
      if let data = response.result.value {
        do {
          let results = try JSONDecoder().decode(RouteResults.self, from: data)
          self.requestStatus = results.connections.isEmpty ? .noResults : .ok
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

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if self.requestStatus == any(of: .ok, .loading) {
      return self.results?.connections.count ?? (self.route == nil ? 0 : 6)
    } else { return 0 }
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "routeResultCell",
                                                   for: indexPath)
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
      guard let destinationViewController = segue.destination
        as? RouteResultsDetailTableViewController else {
          return
      }
      App.log("Routes: Selected \(tableView.indexPathForSelectedRow!.row) row")
      guard let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)
        as? RouteResultsTableViewCell else {
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
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    // swiftlint:disable:previous line_length

    guard let indexPath = tableView.indexPathForRow(at: location)
      else { return nil }

    guard let row = tableView.cellForRow(at: indexPath)
      as? RouteResultsTableViewCell else { return nil }

    let identifier = "routeResultsDetailTableViewController"
    guard let detailVC = storyboard?
      .instantiateViewController(withIdentifier: identifier) as?
      RouteResultsDetailTableViewController else { return nil }

    detailVC.connection = row.connection
    previewingContext.sourceRect = row.frame
    return detailVC
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {

    show(viewControllerToCommit, sender: self)

  }
}

extension RouteResultsTableViewController: RouteSelectionDelegate {
  func routeSelected(_ newRoute: Route) {
    self.route = newRoute
  }
}
