//
//  RouteSettingsTableViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 12/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class RouteSettingsTableViewController: UITableViewController, CurrentRouteDelegate {
  func routeDidUpdated() {
    self.tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    CurrentRouteManager.shared.add(self)
  }
  
  deinit {
    CurrentRouteManager.shared.remove(self)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "routeSettingCell", for: indexPath)
    
    switch indexPath.row {
    case 0:
      cell.textLabel?.text = "Departure"
      cell.detailTextLabel?.text = CurrentRouteManager.shared.departureStop?.name ?? ""
    case 1:
      cell.textLabel?.text = "Arrival"
      cell.detailTextLabel?.text = CurrentRouteManager.shared.arrivalStop?.name ?? ""
    case 2:
      cell.textLabel?.text = "Date"
      let departureSeconds = CurrentRouteManager.shared.departureTime ?? 0
      cell.detailTextLabel?.text = "\(departureSeconds / 3600):\((departureSeconds % 3600) / 60)"
    default:
      App.log("Where am I?!")
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      let vc = storyboard?.instantiateViewController(withIdentifier: "searchForRouteViewController") as! SearchForRouteViewController
      vc.isDepartureStop = true
      self.navigationController?.pushViewController(vc, animated: true)
    case 1:
      let vc = storyboard?.instantiateViewController(withIdentifier: "searchForRouteViewController") as! SearchForRouteViewController
      vc.isDepartureStop = false
      self.navigationController?.pushViewController(vc, animated: true)
    case 2:
      let picker = DateTimePicker.create()
      picker.completionHandler = { date in
        CurrentRouteManager.shared.departureTime = date.toSeconds
        CurrentRouteManager.shared.checkToBuildRoute()
      }
      picker.show()
    default:
      App.log("Where am I?!")
    }
    
  }
}
