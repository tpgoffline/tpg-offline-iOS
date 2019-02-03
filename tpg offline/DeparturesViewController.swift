//
//  DeparturesViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 18/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit
import IntentsUI
import Alamofire

class DeparturesViewController: TableViewController {
  
  var stop: Stop!
  var departureTimer: Timer!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet weak var favoriteImageView: UIImageView!
  @IBOutlet weak var reloadImageView: UIImageView!
  
  var departures: DeparturesGroup = DeparturesGroup(departures: [])
  var noInternet = false
  
  var requestStatus: RequestStatus = .loading {
    didSet {
      tableView.allowsSelection = requestStatus == .ok
      if requestStatus == .loading {
        activityIndicatorView.isHidden = false
        reloadImageView.image = nil
      } else {
        activityIndicatorView.isHidden = true
        reloadImageView.image = #imageLiteral(resourceName: "refresh")
        tableView.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleLabel.text = stop.title
    subTitleLabel.text = stop.subTitle
    subTitleLabel.isHidden = stop.subTitle == ""
    activityIndicatorView.isHidden = false
    reloadImageView.image = nil
    
    let addSiriButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
    addSiriButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
    requestStatus = .ok
    departureTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(reload), userInfo: nil, repeats: true)
    
    DisruptionsMananger.shared.add(self)
    ColorModeManager.shared.add(self)

    favoriteImageView.image = FavoritesManager.shared.stops.contains(stop.appId) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "emptyStar")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    MapManager.shared.centerTo(location: stop.location)
    departureTimer.invalidate()
    departureTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(reload), userInfo: nil, repeats: true)
    reload()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    departureTimer.invalidate()
  }
  
  @IBAction func reload() {
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
            self.requestStatus = .ok
          } catch {
            self.noInternet = true
            if let sbbId = Int(self.stop.sbbId) {
              self.departures = TimetablesManager.shared.offlineDepartures(sbbId: sbbId)
              if self.departures.lines.count == 0 {
                self.requestStatus = .noResults
              } else {
                self.requestStatus = .ok
              }
            }
          }
          
          if self.departures.lines.count == 0 {
            self.requestStatus = .noResults
          }
        } else {
          self.noInternet = true
          if let sbbId = Int(self.stop.sbbId) {
            self.departures = TimetablesManager.shared.offlineDepartures(sbbId: sbbId)
            if self.departures.lines.count == 0 {
              self.requestStatus = .noResults
            } else {
              self.requestStatus = .ok
            }
          }
        }
    }
  }
  
  @IBAction func goBack() {
    self.navigationController?.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showRoute" {
      CurrentRouteManager.shared.departureStop = LocationManager.shared.nearestStops.first
      CurrentRouteManager.shared.arrivalStop = self.stop
      CurrentRouteManager.shared.departureTime = Date.sinceMidnight
    } else if segue.identifier == "showMoreDepartures", let button = sender as? UIButton {
      let line = departures.lines[button.tag]
      let destination = segue.destination as! AllDeparturesForLineViewController
      destination.stop = self.stop
      destination.departures = self.departures
      destination.line = line
    }
  }
  
  deinit {
    DisruptionsMananger.shared.remove(self)
    ColorModeManager.shared.remove(self)
    guard let departureTimer = self.departureTimer else { return }
    departureTimer.invalidate()
  }
}

extension DeparturesViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    
    // 1: Informations (Offline mode, No more vehicules)
    // 2+ Departures
    
    return 1 + departures.lines.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 0
    default:
      let line = departures.lines[section - 1]
      let disruptionsCount: Int
      if DisruptionsMananger.shared.status == .ok, ((DisruptionsMananger.shared.disruptions?.disruptions.index(forKey: line)) != nil) {
        disruptionsCount = DisruptionsMananger.shared.disruptions?.disruptions[line]?.count ?? 0
      } else {
        disruptionsCount = 0
      }
      return disruptionsCount + min(departures.departures.filter({ $0.line.code == line }).count, 6)
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      return UITableViewCell()
    default:
      let section = indexPath.section - 1
      let line = departures.lines[section]
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
      } else if (departures.departures.filter({ $0.line.code == line }).count > 5 && indexPath.row - disruptionsCount == 5) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell",
                                                       for: indexPath)
          as? FooterDeparturesTableViewCell else {
            return UITableViewCell()
        }
        
        cell.button.tag = section
        cell.button.setTitle("Show more", for: [])
        cell.backgroundColor = App.cellBackgroundColor
        
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
        cell.stop = self.stop
        cell.departure = departure
        return cell
      }
    }
  }
  
  @IBAction func toogleFavorite() {
    if let index = FavoritesManager.shared.stops.firstIndex(of: stop.appId) {
      FavoritesManager.shared.stops.remove(at: index)
    } else {
      FavoritesManager.shared.stops.append(stop.appId)
    }
    favoriteImageView.image = FavoritesManager.shared.stops.contains(stop.appId) ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "emptyStar")
  }
  
  func tableView(_ tableView: UITableView,
                 viewForHeaderInSection section: Int) -> UIView? {
    if self.requestStatus == any(of: .error, .noResults) {
      return nil
    } else if section == any(of: 0) {
      return nil
    }
    let section = section - 1
    var line = self.departures.lines[safe: section] ?? "?#!"
    let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
    guard let headerCell = dequeuedCell as? DeparturesHeaderTableViewCell else {
      return UIView()
    }
    
    let color = LineColorManager.color(for: line,
                                       operator: self.stop?.lines[line] ?? .tpg)
    
    if line.count == 2 && line.first == "N" {
      line = Text.noctambus(line)
    }
    headerCell.titleLabel.text = line
    headerCell.titleLabel.textColor = color.contrast
    headerCell.titleRoundedView.backgroundColor = color
    
    if self.stop?.lines[line] == .tac {
      headerCell.subtitleLabel.isHidden = false
      headerCell.subtitleLabel.text = Text.tacNetwork
      headerCell.subtitleLabel.textColor = App.textColor
    } else {
      headerCell.subtitleLabel.isHidden = true
    }
    
    headerCell.accessibilityLabel = Text.departuresFor(line: line)
    
    return headerCell
  }
  
  func tableView(_ tableView: UITableView,
                 heightForHeaderInSection section: Int) -> CGFloat {
    if self.requestStatus == any(of: .error, .noResults) {
      return CGFloat.leastNonzeroMagnitude
    } else if section == any(of: 0) {
      return CGFloat.leastNonzeroMagnitude
    }
    return 44
  }
  
  func tableView(_ tableView: UITableView,
                 heightForFooterInSection section: Int) -> CGFloat {
    if self.requestStatus == any(of: .error, .noResults) {
      return CGFloat.leastNonzeroMagnitude
    } else if section == any(of: 0) {
      return CGFloat.leastNonzeroMagnitude
    }
    let section = section - 1
    let line = self.departures.lines[safe: section] ?? "?#!"
    let count = departures.departures.filter({$0.line.code == line}).count
    if count > 5 {
      //return 88
      return 44
    } else {
      return CGFloat.leastNonzeroMagnitude
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? DeparturesTableViewCell else {
      return
    }
    
    guard let departure = cell.departure else { return }
    
    let busRouteViewController = storyboard?.instantiateViewController(withIdentifier: "BusRouteViewController") as! BusRouteViewController
    busRouteViewController.departure = departure
    busRouteViewController.stop = stop
    self.navigationController?.pushViewController(busRouteViewController, animated: true)
  }
}

extension DeparturesViewController: DisruptionsDelegate {
  func disruptionsDidChange() {
    if requestStatus != .loading {
      self.tableView.reloadData()
    }
  }
}
