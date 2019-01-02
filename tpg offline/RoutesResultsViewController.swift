//
//  RoutesResultsViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 11/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class CurrentRouteManager: NSObject {
  static let shared = CurrentRouteManager()
  
  var departureStop: Stop? = nil
  var arrivalStop: Stop? = nil
  var departureTime: Int? = nil
  
  var route: [[TimetablesManager.Connection]] = []
  
  func checkToBuildRoute() {
    self.route = []
    self.updateRoute()
    
    guard let departureStop = self.departureStop,
      let arrivalStop = self.arrivalStop,
      let departureTime = self.departureTime else {
        return
    }
    
    DispatchQueue.main.async {
      self.route = []
      self.updateRoute()
      TimetablesManager.shared.csa.compute(departureStation: Int(departureStop.sbbId) ?? 0, arrivalStation: Int(arrivalStop.sbbId) ?? 0, departureTime: departureTime) { (connection) in
        self.route.append(connection)
        self.updateRoute()
      }
    }
  }
  
  private var currentRouteDelegates = [CurrentRouteDelegate]()
  
  func add<T>(_ delegate: T) where
    T: CurrentRouteDelegate, T: Equatable {
      currentRouteDelegates.append(delegate)
  }
  
  func remove<T>(_ delegate: T) where
    T: CurrentRouteDelegate, T: Equatable {
      for (index, currentRouteDelegate) in currentRouteDelegates.enumerated() {
        if let currentRouteDelegate = currentRouteDelegate as? T,
          currentRouteDelegate == delegate {
          currentRouteDelegates.remove(at: index)
          break
        }
      }
  }
  
  func updateRoute() {
    DispatchQueue.main.async {
      self.currentRouteDelegates.forEach { $0.routeDidUpdated() }
    }
  }
}

protocol CurrentRouteDelegate: class {
  func routeDidUpdated()
}

class RoutesResultsViewController: TableViewController {
  
  @IBOutlet weak var progressView: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.progressView.setProgress(0, animated: true)
    self.tableView.reloadData()
    CurrentRouteManager.shared.checkToBuildRoute()
    CurrentRouteManager.shared.add(self)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    if isMovingFromParent {
      TimetablesManager.shared.csa.breakProcess = true
    }
  }
  
  deinit {
    CurrentRouteManager.shared.remove(self)
  }
}

extension RoutesResultsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CurrentRouteManager.shared.route.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "routeResultCell", for: indexPath) as! RouteResultCell
    cell.connection = CurrentRouteManager.shared.route[indexPath.row]
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showPreview" {
      let destinationVC = segue.destination as! RoutePreviewViewController
      destinationVC.connection = CurrentRouteManager.shared.route[tableView.indexPathForSelectedRow?.row ?? 0]
    }
  }
}

extension RoutesResultsViewController: CurrentRouteDelegate {
  func routeDidUpdated() {
    //tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    tableView.reloadData()
    progressView.setProgress(Float(TimetablesManager.shared.csa.progress), animated: true)
  }
}

class RouteResultCell: UITableViewCell {
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var routePreviewView: RoutePreviewView!
  
  var connection: [TimetablesManager.Connection] = [] {
    didSet {
      guard let departureSeconds = connection.first?.departureSeconds,
        let arrivalSeconds = connection.last?.arrivalSeconds else {
          return
      }
      departureTimeLabel.text = "\(departureSeconds / 3600):\((departureSeconds % 3600) / 60)"
      arrivalTimeLabel.text = "\(arrivalSeconds / 3600):\((arrivalSeconds % 3600) / 60)"
      routePreviewView.connection = connection
    }
  }
}
