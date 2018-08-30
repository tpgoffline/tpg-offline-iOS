//
//  RouteResultsDetailTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 10/09/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class RouteResultsDetailTableViewController: UITableViewController {
  
  var connection: RouteConnection?
  var zones: [Int] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Result".localized
    
    var stopsId = connection!.sections!.map({ $0.departure.station.id })
    stopsId += connection!.sections!.map({ $0.arrival.station.id })
    var stops: [Stop] = []
    for e in stopsId {
      if let stop = App.stops.filter({ $0.sbbId == e })[safe: 0] {
        stops.append(stop)
      }
    }
    for zone in stops.map({$0.pricingZone}) {
      zones += zone
    }
    zones = zones.uniqueElements
    
    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }
    
    ColorModeManager.shared.addColorModeDelegate(self)
    
    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }
    
    navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: "Go!".localized,
                      style: .plain,
                      target: self,
                      action: #selector(self.goMode))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showStep" {
      guard let destinationViewController = segue.destination
        as? RouteStepViewController else { return }
      guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
      guard let row = tableView.cellForRow(at: selectedIndexPath)
        as? RouteResultDetailsTableViewCell else { return }
      
      destinationViewController.section = row.section
      App.log("Routes: Selected \(selectedIndexPath.row) detail row")
    } else if segue.identifier == "showMap" {
      guard let destinationViewController = segue.destination
        as? RouteMapViewController else { return }
      guard let connection = connection else { return }
      destinationViewController.connection = connection
      App.log("Routes: Show map")
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2 + (connection?.sections?.count ?? 0)
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return zones.count > 1 ? 1 : 0
    case (connection?.sections?.count ?? 0) + 1:
      return 1
    default:
      return 1
    }
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "warningCell",
                                               for: indexPath)
      
      let titleAttributes =
        [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
         NSAttributedStringKey.foregroundColor: App.darkMode ? #colorLiteral(red: 1, green: 0.9215686275, blue: 0.231372549, alpha: 1) : App.textColor]
          as [NSAttributedStringKey: Any]
      cell.textLabel?.numberOfLines = 0
      cell.textLabel?.attributedText =
        NSAttributedString(string: Text.regionalRoute,
                           attributes: titleAttributes)
      var zonesText = ""
      zones.forEach({ zonesText.append("\($0) / ")})
      zonesText.removeLast()
      zonesText.removeLast()
      let text = NSMutableAttributedString()
      text.normal(Text.routeCrossZones)
      text.bold(zonesText)
      cell.detailTextLabel?.attributedText = text
      cell.detailTextLabel?.numberOfLines = 0
      cell.selectionStyle = .none
      
      cell.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.9215686275, blue: 0.231372549, alpha: 1)
      return cell
    } else if indexPath.section == (connection?.sections?.count ?? 0) + 1 {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell",
                                                     for: indexPath)
        as? RouteResultsDetailMapTableViewCell, let connection = connection else {
          return UITableViewCell()
      }
      cell.connection = connection
      cell.mapView.addGestureRecognizer(
        UITapGestureRecognizer(target: self,
                               action: #selector(self.pushMap)))
      
      return cell
    } else {
      if connection?.sections?[safe: indexPath.section - 1]?.walk != nil {
        let cell =
          tableView.dequeueReusableCell(withIdentifier: "walkConnectionCell",
                                        for: indexPath)
        if let duration =
          connection?.sections?[safe: indexPath.section - 1]?.walk?.duration,
          duration != 0 {
          cell.textLabel?.text = String(format: "Walk %@m".localized, "\(duration)")
        } else {
          cell.textLabel?.text = "Walk".localized
        }
        cell.textLabel?.textColor = App.textColor
        cell.imageView?.image = #imageLiteral(resourceName: "transfer").maskWith(color: App.textColor)
        cell.selectionStyle = .none
        cell.backgroundColor = App.cellBackgroundColor
        return cell
      } else {
        guard let cell =
          tableView.dequeueReusableCell(withIdentifier: "resultDetailCell",
                                        for: indexPath)
            as? RouteResultDetailsTableViewCell,
          let section = connection?.sections?[safe: indexPath.section - 1] else {
            return UITableViewCell()
        }
        cell.section = section
        return cell
      }
    }
    
  }
  
  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    
    if section == 0 || section == (connection?.sections?.count ?? 0) + 1 {
      return nil
    }
    
    guard
      let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell"),
      let section = connection?.sections?[safe: section - 1] else {
        return UIView()
    }
    if section.walk != nil { return nil }
    let destinationName = (section.journey?.to ?? "").toStopName
    
    var titleAttributes =
      [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        as [NSAttributedStringKey: Any]
    
    if section.journey?.compagny == "TPG" {
      headerCell.backgroundColor = App.darkMode ? App.cellBackgroundColor :
        App.color(for: section.journey?.lineCode ?? "")
      titleAttributes[NSAttributedStringKey.foregroundColor] = App.darkMode ?
        App.color(for: section.journey?.lineCode ?? "") :
        App.color(for: section.journey?.lineCode ?? "").contrast
    } else if section.journey?.compagny == "SBB" {
      headerCell.textLabel?.text = Text.sbb(line: section.journey?.lineCode,
                                            destination: destinationName)
      headerCell.backgroundColor = App.darkMode ? App.cellBackgroundColor : .red
      titleAttributes[NSAttributedStringKey.foregroundColor] = App.darkMode ?
        UIColor.red : UIColor.white
    } else {
      headerCell.backgroundColor = App.darkMode ? .black : .white
      titleAttributes[NSAttributedStringKey.foregroundColor] = App.darkMode ?
        UIColor.white : UIColor.black
    }
    headerCell.textLabel?.attributedText =
      NSAttributedString(string:
        Text.line(section.journey?.lineCode,
                  destination: destinationName),
                         attributes: titleAttributes)
    return headerCell
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 || section == (connection?.sections?.count ?? 0) + 1 {
      return 0
    }
    if connection?.sections?[safe: section - 1]?.walk != nil {
      return 0
    }
    return 44
  }
  
  @objc func pushMap() {
    //if connection.
    performSegue(withIdentifier: "showMap", sender: self)
  }
  
  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension RouteResultsDetailTableViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    // swiftlint:disable:previous line_length
    
    guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
    
    guard let row = tableView.cellForRow(at: indexPath)
      as? RouteResultDetailsTableViewCell else { return nil }
    
    guard let detailVC = storyboard?
      .instantiateViewController(withIdentifier: "routeStepViewController") as?
      RouteStepViewController else { return nil }
    
    detailVC.section = row.section
    previewingContext.sourceRect = row.frame
    return detailVC
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
  
  @objc func goMode() {
    if !UserDefaults.standard.bool(forKey: "firstTimeGoMode") {
      UserDefaults.standard.set(true, forKey: "firstTimeGoMode")
      let alert = UIAlertController(title: Text.goMode,
                                    message: Text.goModeHelp,
                                    preferredStyle: .alert)
      let continueAction = UIAlertAction(title: Text.continue,
                                         style: .default) { (_) in
                                          self.goMode()
      }
      let cancelAction = UIAlertAction(title: Text.cancel,
                                       style: .default,
                                       handler: nil)
      
      alert.addAction(cancelAction)
      alert.addAction(continueAction)
      self.present(alert, animated: true, completion: nil)
    } else if let departureTimestamp = connection?.from.departureTimestamp {
      let alert = UIAlertController(title: Text.reminder,
                                    message: Text.goModeReminder,
                                    preferredStyle: .alert)
      if departureTimestamp.distance(to: Int(Date().timeIntervalSince1970)) >= -300 {
        self.setGoMode(minutes: -1)
        return
      }
      if departureTimestamp.distance(to: Int(Date().timeIntervalSince1970)) < -300 {
        let fiveMinutesAction = UIAlertAction(title: Text.fiveMinutesBefore,
                                              style: .default) { (_) in
                                                self.setGoMode(minutes: 5)
        }
        alert.addAction(fiveMinutesAction)
      }
      if departureTimestamp.distance(to: Int(Date().timeIntervalSince1970)) < -600 {
        let tenMinutesAction = UIAlertAction(title: Text.tenMinutesBefore,
                                             style: .default) { (_) in
                                              self.setGoMode(minutes: 10)
        }
        alert.addAction(tenMinutesAction)
      }
      if departureTimestamp.distance(to: Int(Date().timeIntervalSince1970)) < -900 {
        let fifteenMinutesAction = UIAlertAction(title: Text.fifteenMinutesBefore,
                                                 style: .default) { (_) in
                                                  self.setGoMode(minutes: 15)
        }
        alert.addAction(fifteenMinutesAction)
      }
      let doNotSetReminderAction = UIAlertAction(title: Text.doNotSetReminder,
                                               style: .default) { (_) in
                                                self.setGoMode(minutes: -1)
      }
      alert.addAction(doNotSetReminderAction)
      
      let cancelAction = UIAlertAction(title: Text.cancel,
                                       style: .default,
                                       handler: nil)
      
      alert.addAction(cancelAction)
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func setGoMode(minutes: Int) {
    guard let sections = connection?.sections else {
      return
    }
    
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
    
    var locationAllowed: Bool
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied:
        locationAllowed = false
      case .authorizedAlways, .authorizedWhenInUse:
        locationAllowed = true
      }
    } else {
      locationAllowed = false
    }
    
    if let departureTimestamp = connection?.from.departureTimestamp, minutes != -1 {
      let dateComponents =
        Calendar.current.dateComponents([.hour,
                                         .minute,
                                         .day,
                                         .month,
                                         .year],
                                        from:
          Date(timeIntervalSince1970:
            Double(departureTimestamp))
            .addingTimeInterval(TimeInterval(-60 * minutes)))
      
      if #available(iOS 10.0, *) {
        let content = UNMutableNotificationContent()
        content.title = Text.goTimeToGo
        content.body = Text.take(line: sections[0].journey?.lineCode ?? "",
                                 to: sections[0].journey?.to.toStopName ?? "",
                                 in: minutes) + Text.pushToShowMap
        content.categoryIdentifier = "departureNotification"
        
        var departureLocalisations = App.stops.filter({
          $0.sbbId == sections[0].departure.station.id
        })[safe: 0]?.localisations ?? []
        for (indexA, x) in departureLocalisations.enumerated() {
          departureLocalisations[indexA].destinations = x.destinations.filter({ $0.destinationTransportAPI == (sections[0].journey?.to ?? "")
          })
        }
        
        if let departureLocalisation = departureLocalisations.filter({ !$0.destinations.isEmpty })[safe: 0]  {
          content.userInfo = [
            "x": departureLocalisation.location.coordinate.latitude,
            "y": departureLocalisation.location.coordinate.longitude,
            "stopName":  sections[0].departure.station.name.toStopName
          ]
        } else {
          content.userInfo = [
            "x": sections[0].departure.station.coordinate.x,
            "y": sections[0].departure.station.coordinate.y,
            "stopName": sections[0].departure.station.name.toStopName
          ]
        }
        
        let trigger =
          UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                        repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content,
                                            trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
          if let error = error {
            print(error)
          }
        }
      } else {
        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSince1970: Double(departureTimestamp)).addingTimeInterval(TimeInterval(-60 * minutes))
        notification.alertBody = Text.take(line: sections[0].journey?.lineCode ?? "",
                                           to: sections[0].journey?.to ?? "",
                                           in: minutes)
        notification.identifier = "departureNotification-\(String.random(30))"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
      }
    }
    
    let filtredSection = sections.filter({ $0.journey != nil && $0.walk == nil })
    for (index, section) in filtredSection.enumerated() {
      let arrivalName = section.arrival.station.name.toStopName
      let passList = section.journey!.passList
      if #available(iOS 10.0, *) {
        let content = UNMutableNotificationContent()
        content.title = Text.goNextStop
        
        if index == sections.count - 1 {
          content.body = Text.rememberLeaveDestination(stop: arrivalName) + Text.pushToShowMap
        } else {
          content.body =
            Text.rememberLeaveLine(stop: section.arrival.station.name.toStopName,
                                   line: sections[index + 1].journey?.lineCode) + Text.pushToShowMap
        }
        
        content.categoryIdentifier = "goNotification"
        
        if index == filtredSection.endIndex - 1 {
          content.userInfo = [
            "arrivalX": section.arrival.station.coordinate.x,
            "arrivalY": section.arrival.station.coordinate.y,
            "arrivalName": arrivalName
          ]
        } else {
          let departureName = filtredSection[index + 1].departure.station.name.toStopName
          
          var departureLocalisations = App.stops.filter({
            $0.sbbId == section.arrival.station.id
          })[safe: 0]?.localisations ?? []
          for (indexA, x) in departureLocalisations.enumerated() {
            departureLocalisations[indexA].destinations = x.destinations.filter({ $0.destinationTransportAPI == section.journey?.to
            })
          }
          
          var arrivalLocalisations = App.stops.filter({
            $0.sbbId == filtredSection[index + 1].departure.station.id
          })[safe: 0]?.localisations ?? []
          for (indexA, x) in arrivalLocalisations.enumerated() {
            arrivalLocalisations[indexA].destinations = x.destinations.filter({ $0.destinationTransportAPI == filtredSection[index + 1].journey?.to
            })
          }
          
          if let departureLocalisation = departureLocalisations.filter({ !$0.destinations.isEmpty })[safe: 0],
            let arrivalLocalisation = arrivalLocalisations.filter({ !$0.destinations.isEmpty })[safe: 0] {
            content.userInfo = [
              "arrivalX": arrivalLocalisation.location.coordinate.latitude,
              "arrivalY": arrivalLocalisation.location.coordinate.longitude,
              "arrivalName": departureName,
              "departureX": departureLocalisation.location.coordinate.latitude,
              "departureY": departureLocalisation.location.coordinate.longitude,
              "departureName": arrivalName
            ]
          } else {
            content.userInfo = [
              "arrivalX": section.arrival.station.coordinate.x,
              "arrivalY": section.arrival.station.coordinate.y,
              "arrivalName": arrivalName
            ]
          }
        }
        
        let request: UNNotificationRequest
        if locationAllowed {
          let center = CLLocationCoordinate2D(latitude:
            passList[passList.endIndex - 1].station.coordinate.x,
                                              longitude:
            passList[passList.endIndex - 1].station.coordinate.y)
          let region = CLCircularRegion(center: center,
                                        radius: 200.0,
                                        identifier:
            passList[passList.endIndex - 1].station.id)
          region.notifyOnEntry = true
          region.notifyOnExit = false
          let trigger = UNLocationNotificationTrigger(region: region,
                                                      repeats: false)
          let uuidString = UUID().uuidString
          request = UNNotificationRequest(identifier: uuidString,
                                          content: content,
                                          trigger: trigger)
        } else {
          let dateComponents =
            Calendar.current.dateComponents([.hour,
                                             .minute,
                                             .day,
                                             .month,
                                             .year],
                                            from:
              Date(timeIntervalSince1970:
                Double(passList[passList.endIndex - 1].arrivalTimestamp ?? 0)).addingTimeInterval(-120))
          
          let trigger =
            UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                          repeats: false)
          let uuidString = UUID().uuidString
          request = UNNotificationRequest(identifier: uuidString,
                                          content: content,
                                          trigger: trigger)
        }
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
          if let error = error {
            print(error)
          }
        }
        
        let alert = UIAlertController(title: Text.goModeActivated,
                                      message: Text.goModeActivatedSubtitle,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.ok,
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
      } else {
        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSince1970:
          Double(passList[passList.endIndex - 2].arrivalTimestamp ?? 0))
        if index == sections.count - 1 {
          notification.alertBody =
            Text.rememberLeaveDestination(stop: arrivalName)
        } else {
          notification.alertBody =
            Text.rememberLeaveLine(stop: section.arrival.station.name.toStopName,
                                   line: sections[index + 1].journey?.lineCode)
        }
        notification.identifier = "departureNotification-\(String.random(30))"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
      }
    }
  }
}
