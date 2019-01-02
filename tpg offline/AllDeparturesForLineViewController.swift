//
//  AllDeparturesForLineViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 04/12/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class AllDeparturesForLineViewController: TableViewController, UITableViewDataSource {
  
  var departures: DeparturesGroup = DeparturesGroup(departures: [])
  var filteredDepartures: [Departure] = []
  var line = ""
  var stop: Stop!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    filteredDepartures = departures.departures.filter({ $0.line.code == line })
    self.tableView.dataSource = self
    self.tableView.delegate = self
    DisruptionsMananger.shared.add(self)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let disruptionsCount: Int
    if DisruptionsMananger.shared.status == .ok, ((DisruptionsMananger.shared.disruptions?.disruptions.index(forKey: line)) != nil) {
      disruptionsCount = DisruptionsMananger.shared.disruptions?.disruptions[line]?.count ?? 0
    } else {
      disruptionsCount = 0
    }
    return filteredDepartures.count + disruptionsCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let disruptionsCount: Int
    if DisruptionsMananger.shared.status == .ok, ((DisruptionsMananger.shared.disruptions?.disruptions.index(forKey: line)) != nil) {
      disruptionsCount = DisruptionsMananger.shared.disruptions?.disruptions[line]?.count ?? 0
    } else {
      disruptionsCount = 0
    }
    
    if indexPath.row < disruptionsCount {
      let cell = tableView.dequeueReusableCell(withIdentifier: "disruptionCell",
                                               for: indexPath)
      let disruption = DisruptionsMananger.shared.disruptions?.disruptions[line]?[indexPath.row]
      cell.imageView?.tintColor = .black
      cell.imageView?.image = #imageLiteral(resourceName: "warning")
      cell.textLabel?.numberOfLines = 0
      cell.detailTextLabel?.numberOfLines = 0
      cell.textLabel?.text = disruption?.nature
        .replacingOccurrences(of: "  ", with: " ")
        .replacingOccurrences(of: "' ", with: "'")
      if disruption?.place != "" {
        let disruptionPlace = disruption?.place
          .replacingOccurrences(of: "  ", with: " ")
          .replacingOccurrences(of: "' ", with: "'")
        cell.textLabel?.text = cell.textLabel?.text?.appending(" - \(disruptionPlace ?? "")")
      }
      cell.detailTextLabel?.text = disruption?.consequence
        .replacingOccurrences(of: "  ", with: " ")
        .replacingOccurrences(of: "' ", with: "'")
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell",
                                                     for: indexPath)
        as? DeparturesTableViewCell else {
          return UITableViewCell()
      }
      
      let departure: Departure?
      departure = departures.departures.filter({
        $0.line.code == line
      })[indexPath.row - disruptionsCount]
      cell.stop = stop
      cell.departure = departure
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? DeparturesTableViewCell else {
      return
    }
    
    guard let departure = cell.departure else { return }
    
    let busRouteViewController = storyboard?.instantiateViewController(withIdentifier: "BusRouteViewController") as! BusRouteViewController
    busRouteViewController.departure = departure
    self.navigationController?.pushViewController(busRouteViewController, animated: true)
  }
}

extension AllDeparturesForLineViewController: DisruptionsDelegate {
  func disruptionsDidChange() {
    self.tableView.reloadData()
  }
}
