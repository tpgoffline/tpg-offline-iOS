//
//  DetailDeparturesViewController.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 11/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import Mapbox
import MessageUI
#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

class DetailDeparturesViewController: UIViewController {

  @IBOutlet weak var reminderButton: UIButton!
  @IBOutlet weak var allDeparturesButton: UIButton!
  @IBOutlet weak var wifiButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var mapView: MGLMapView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var buttonsView: UIView!

  var departure: Departure?
  var busRouteGroup: BusRouteGroup? {
    didSet {
      self.tableView.reloadData()
      
      mapView.styleURL = URL.mapUrl
      mapView.reloadStyle(self)
      
      if let annotations = mapView.annotations {
        mapView.removeAnnotations(annotations)
      }

      guard let busRouteGroup = self.busRouteGroup else { return }

      let indexPath = IndexPath(row: (busRouteGroup.steps.count) -
        (busRouteGroup.steps.filter({ $0.arrivalTime != "" }).count), section: 0)
      if self.tableView.numberOfRows(inSection: 0) > indexPath.row {
        DispatchQueue.main.async {
          self.tableView.scrollToRow(at: indexPath,
                                     at: UITableView.ScrollPosition.top,
                                     animated: false)
        }
      }

      let steps = busRouteGroup.steps
      var coordinates: [CLLocationCoordinate2D] = []
      var passedCoordinated: [CLLocationCoordinate2D] = []
      var passed = true
      for step in steps {
        guard let stop = App.stops.filter({ $0.code == step.stop.code })[safe: 0]
          else { continue }
        let annotation = MGLPointAnnotation()
        if let localisation = stop.localisations.filter({
          !($0.destinations.filter({
            $0.line == busRouteGroup.lineCode &&
              $0.destination == busRouteGroup.destination
          }).isEmpty) })[safe: 0] {
          annotation.coordinate = localisation.location.coordinate
        } else {
          annotation.coordinate = stop.location.coordinate
        }

        if step.arrivalTime == "" {
          passedCoordinated.append(annotation.coordinate)
        } else if step.arrivalTime != "", passed {
          passedCoordinated.append(annotation.coordinate)
          coordinates.append(annotation.coordinate)
          passed = false
        } else {
          coordinates.append(annotation.coordinate)
        }

        annotation.title = stop.name
        self.names.append(stop.name)
        mapView.addAnnotation(annotation)
      }

      let geodesicPassed = MGLPolyline(coordinates: &passedCoordinated,
                                       count: UInt(passedCoordinated.count))
      geodesicPassed.title = Text.passedStops
      mapView.addAnnotation(geodesicPassed)
      let geodesic = MGLPolyline(coordinates: &coordinates,
                                 count: UInt(coordinates.count))
      geodesic.title = Text.nextStops
      mapView.addAnnotation(geodesic)

      let centerPoint: CLLocationCoordinate2D
      if busRouteGroup.steps.filter({
        $0.stop.code == self.stop?.code
      })[0].arrivalTime == "" {
        guard let i = busRouteGroup.steps.filter({
          $0.arrivalTime != ""
        })[safe: 0] else {
          let coordinate: CLLocationCoordinate2D
          if let lastCoordinate = coordinates.last {
            coordinate = lastCoordinate
          } else {
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
          }
          mapView.setCenter(coordinate, zoomLevel: 14, animated: false)
          return
        }
        let nextStop = i.stop.code
        if let stop = App.stops.filter({ $0.code == nextStop })[safe: 0] {
          centerPoint = stop.location.coordinate
        } else {
          centerPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
      } else {
        if coordinates.count == 0 {
          centerPoint = stop?.location.coordinate ??
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        } else {
          centerPoint = coordinates.filter({
            $0 == (self.stop!.location.coordinate)
          })[safe: 0] ?? coordinates[0]
        }
      }
      mapView.setCenter(centerPoint, zoomLevel: 14, animated: false)
    }
  }
  var color: UIColor?
  var stop: Stop?
  var names: [String] = []

  var titleSelected = "" {
    didSet {
      self.tableView.reloadData()
    }
  }

  private let refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = Text.line(departure?.line.code)

    if App.darkMode {
      self.buttonsView.backgroundColor = .black
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }

    if let color = self.color {
      let buttonColor = (App.darkMode ? color : color.contrast)
      let backgroundButtonColor = (App.darkMode ? App.cellBackgroundColor :
        color)

      self.reminderButton.setImage(#imageLiteral(resourceName: "cel-bell").maskWith(color: buttonColor),
                                   for: .normal)
      self.allDeparturesButton.setImage(#imageLiteral(resourceName: "clockTabBar").maskWith(color: buttonColor),
                                        for: .normal)
      self.wifiButton.setImage(#imageLiteral(resourceName: "wifi").maskWith(color: buttonColor),
                               for: .normal)

      self.reminderButton.setTitleColor(buttonColor, for: .normal)
      self.reminderButton.backgroundColor = backgroundButtonColor
      self.reminderButton.cornerRadius = 5
      self.allDeparturesButton.setTitleColor(buttonColor, for: .normal)
      self.allDeparturesButton.backgroundColor = backgroundButtonColor
      self.allDeparturesButton.cornerRadius = 5
      self.wifiButton.setTitleColor(buttonColor, for: .normal)
      self.wifiButton.backgroundColor = backgroundButtonColor
      self.wifiButton.cornerRadius = 5
    }

    refreshBusRoute()

    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      self.tableView.addSubview(refreshControl)
    }

    refreshControl.addTarget(self,
                             action: #selector(refreshBusRoute),
                             for: .valueChanged)
    refreshControl.tintColor = color

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.refreshBusRoute),
                      accessbilityLabel: Text.reload)
    ]

    if UIDevice.current.orientation.isLandscape,
      UIDevice.current.userInterfaceIdiom == .phone {
      self.stackView.axis = .horizontal
    } else {
      self.stackView.axis = .vertical
    }

    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: self.tableView)
    }

    if self.departure?.wifi == false {
      self.wifiButton.isHidden = true
    }
    if #available(iOS 11.0, *) {} else {
      self.wifiButton.isHidden = true
    }
    #if !arch(i386) && !arch(x86_64)
    #else
    self.wifiButton.isHidden = true
    #endif

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.buttonsView.backgroundColor = App.darkMode ? .black : .white
    self.tableView.backgroundColor = App.darkMode ? .black : .white
    self.tableView.separatorColor = App.separatorColor
    self.tableView.reloadData()
    
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)

    if let color = self.color {
      let buttonColor = (App.darkMode ? color : color.contrast)
      let buttonBackgroundColor = (App.darkMode ? App.cellBackgroundColor : color)
      self.reminderButton.setImage(#imageLiteral(resourceName: "cel-bell").maskWith(color: buttonColor),
                                   for: .normal)
      self.allDeparturesButton.setImage(#imageLiteral(resourceName: "clockTabBar").maskWith(color: buttonColor),
                                        for: .normal)

      self.reminderButton.setTitleColor(buttonColor, for: .normal)
      self.reminderButton.backgroundColor = buttonBackgroundColor
      self.allDeparturesButton.setTitleColor(buttonColor, for: .normal)
      self.allDeparturesButton.backgroundColor = buttonBackgroundColor
      self.wifiButton.setTitleColor(buttonColor, for: .normal)
      self.wifiButton.backgroundColor = buttonBackgroundColor
    }
  }

  @objc func refreshBusRoute() {
    self.busRouteGroup = nil
    Alamofire.request(URL.thermometer,
                      method: .get,
                      parameters: ["key": API.tpg,
                                   "departureCode": departure?.code ?? 0])
      .responseData { (response) in
        if let data = response.result.value {
          let jsonDecoder = JSONDecoder()
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
          let json = try? jsonDecoder.decode(BusRouteGroup.self, from: data)

          self.busRouteGroup = json
        }
        self.refreshControl.endRefreshing()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showStopFromBusRoute" {
      guard let destinationViewController = segue.destination as?
        DeparturesViewController else {
          return
      }
      let indexPath = tableView.indexPathForSelectedRow!
      self.tableView.deselectRow(at: indexPath, animated: true)
      destinationViewController.stop = App.stops.filter({
        let cell = tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell
        return $0.code == cell?.busRoute?.stop.code
      })[safe: 0]
    } else if segue.identifier == "allDepartures" {
      App.log("Departures: Show all departures")
      guard let destinationViewController = segue.destination as?
        AllDeparturesCollectionViewController else {
          return
      }
      destinationViewController.departure = self.departure
      destinationViewController.stop = self.stop
    }
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    // swiftlint:disable:previous line_length
    if UIDevice.current.orientation.isLandscape,
      UIDevice.current.userInterfaceIdiom == .phone {
      self.stackView.axis = .horizontal
    } else {
      self.stackView.axis = .vertical
    }
  }

  @IBAction func connectToWifi() {
    #if !arch(i386) && !arch(x86_64)
    if #available(iOS 11.0, *) {
      let configuration = NEHotspotConfiguration(ssid: "tpg-freeWiFi")
      configuration.joinOnce = false
      NEHotspotConfigurationManager.shared.apply(configuration,
                                                 completionHandler: { (error) in
                                                  print(error ?? "Unknow error")
      })
    } else {
      print("How did you ended here ?")
    }
    #endif
  }

  @IBAction func remind() {
    App.log("Departures: Reminder")
    self.departure?.calculateLeftTime()
    let leftTime = Int(self.departure?.leftTime ?? "0".localized) ?? 0
    var alertController = UIAlertController(title: Text.reminder,
                                            message: Text.whenReminder,
                                            preferredStyle: .alert)
    if self.departure?.leftTime == "0" {
      alertController.title = Text.busIsComming
      alertController.message = Text.cantSetATimer
    } else {
      let departureTimeAction = UIAlertAction(title: Text.atDepartureTime,
                                              style: .default) { _ in
        self.setAlert(with: 0,
                      date: (self.departure?.dateCompenents?.date ?? Date()),
                      fromName: self.stop?.name ?? "",
                      fromCode: self.stop?.code ?? "")
      }
      alertController.addAction(departureTimeAction)

      if leftTime > 5 {
        let actionName = Text.fiveMinutesBefore
        let fiveMinutesBeforeAction = UIAlertAction(title: actionName,
                                                    style: .default) { _ in
          self.setAlert(with: 5,
                        date: (self.departure?.dateCompenents?.date ?? Date()),
                        fromName: self.stop?.name ?? "",
                        fromCode: self.stop?.code ?? "")
        }
        alertController.addAction(fiveMinutesBeforeAction)
      }
      if leftTime > 10 {
        let actionName = Text.tenMinutesBefore
        let tenMinutesBeforeAction = UIAlertAction(title: actionName,
                                                   style: .default) { _ in
          self.setAlert(with: 10,
                        date: (self.departure?.dateCompenents?.date ?? Date()),
                        fromName: self.stop?.name ?? "",
                        fromCode: self.stop?.code ?? "")
        }
        alertController.addAction(tenMinutesBeforeAction)
      }
      let otherAction = UIAlertAction(title: Text.other,
                                      style: .default) { _ in
        alertController.dismiss(animated: true, completion: nil)
        alertController = UIAlertController(title: Text.fiveMinutesBefore,
                                            message: Text.whenReminder,
                                            preferredStyle: .alert)

        alertController.addTextField { textField in
          textField.placeholder = Text.numberMinutesBeforeDepartures
          textField.keyboardType = .numberPad
          textField.keyboardAppearance = App.darkMode ? .dark : .light
        }

        let okAction = UIAlertAction(title: Text.ok, style: .default) { _ in
          guard let text = alertController.textFields?[0].text else { return }
          guard let remainingTime = Int(text) else { return }
          self.setAlert(with: remainingTime,
                        date: (self.departure?.dateCompenents?.date ?? Date()),
                        fromName: self.stop?.name ?? "",
                        fromCode: self.stop?.code ?? "")
        }
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: Text.cancel,
                                         style: .destructive) { _ in
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
      }

      alertController.addAction(otherAction)
    }

    let cancelAction = UIAlertAction(title: Text.cancel,
                                     style: .destructive) { _ in }
    alertController.addAction(cancelAction)

    present(alertController, animated: true, completion: nil)
  }

  func setAlert(with timeBefore: Int,
                date: Date,
                fromName: String,
                fromCode: String,
                forceDisableSmartReminders: Bool = false) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) {(accepted, _) in
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

    UIApplication.shared.registerForRemoteNotifications()

    let newDate = date.addingTimeInterval(TimeInterval(timeBefore * -60))
    let components = Calendar.current.dateComponents([.hour,
                                                      .minute,
                                                      .day,
                                                      .month,
                                                      .year], from: newDate)
    if App.smartReminders,
      !forceDisableSmartReminders,
      let departure = self.departure,
      departure.code != -1 {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      var parameters: Parameters = [
        "departureCode": departure.code,
        "title": timeBefore == 0 ?
          Text.busIsCommingNow : Text.minutesLeft(timeBefore),
        "text": Text.take(line: departure.line.code,
                          to: departure.line.destination),
        "line": departure.line.code,
        "reminderTimeBeforeDeparture": timeBefore,
        "stopCode": fromCode,
        "estimatedArrivalTime": formatter.string(from: date),
        "sandbox": false
      ]
      #if DEBUG
      parameters["sandbox"] = true
      #endif
      Alamofire
        .request(URL.smartReminders,
                        method: .post,
                        parameters: parameters)
        .responseString(completionHandler: { (response) in
        dump(response)
        if let string = response.result.value, string == "1" {
          let alertMessage = Text.notificationWillBeSend(minutes: timeBefore)
          let alertController = UIAlertController(title: Text.youWillBeReminded,
                                                  message: alertMessage,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: Text.ok,
                                                  style: .default,
                                                  handler: nil))
          self.present(alertController, animated: true, completion: nil)
        } else if let string = response.result.value, string == "0" {
          let alertController = UIAlertController(title: Text.duplicateReminder,
                                                  message: Text.alreadySheduled,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: Text.ok,
                                                  style: .default,
                                                  handler: nil))
          self.present(alertController, animated: true, completion: nil)
        } else {
          let alertMessage = Text.cantAddSmartReminder
          let alertController = UIAlertController(title: Text.error,
                                                  message: alertMessage,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: Text.tryAgain,
                                                  style: .default,
                                                  handler: { (_) in
            self.setAlert(with: timeBefore,
                          date: newDate,
                          fromName: fromName,
                          fromCode: fromCode,
                          forceDisableSmartReminders: false)
          }))
          let actionTitle = Text.tryAgainWithoutSmartRemiders
          alertController.addAction(UIAlertAction(title: actionTitle,
                                                  style: .default,
                                                  handler: { (_) in
            self.setAlert(with: timeBefore,
                          date: newDate,
                          fromName: fromName,
                          fromCode: fromCode,
                          forceDisableSmartReminders: true)
          }))
          alertController.addAction(UIAlertAction(title: Text.cancel,
                                                  style: .cancel,
                                                  handler: nil))
          self.present(alertController, animated: true, completion: nil)
        }
      })
    } else {
      guard let departure = departure else { return }
      if #available(iOS 10.0, *) {
        dump(components)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: false)
        let content = UNMutableNotificationContent()

        content.title = timeBefore == 0 ?
          Text.busIsCommingNow : Text.minutesLeft(timeBefore)
        content.body = Text.take(line: departure.line.code,
                                 to: departure.line.destination)
        content.sound = UNNotificationSound.default
        let notificationIdentifier = "departureNotification-\(String.random(30))"
        let request = UNNotificationRequest(identifier: notificationIdentifier,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
          if let error = error {
            print("Uh oh! We had an error: \(error)")
            let alertController = UIAlertController(title: Text.error,
                                                    message: Text.sorryError,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Text.ok,
                                                    style: .default,
                                                    handler: nil))
            alertController.addAction(UIAlertAction(title: "Send email",
                                                    style: .default,
                                                    handler: { (_) in
              let mailComposerVC = MFMailComposeViewController()
              mailComposerVC.mailComposeDelegate = self

              mailComposerVC.setToRecipients(["support@asmartcode.com"])
              mailComposerVC.setSubject("tpg offline - Bug report")
              mailComposerVC.setMessageBody("\(error.localizedDescription)",
                isHTML: false)

              if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC, animated: true, completion: nil)
              }
            }))

            self.present(alertController, animated: true, completion: nil)
          } else {
            let alertMessage = Text.notificationWillBeSend(minutes: timeBefore)
            let alertController = UIAlertController(title: Text.youWillBeReminded,
                                                    message: alertMessage,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Text.ok,
                                                    style: .default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
          }
        }
      } else {
        let notification = UILocalNotification()
        notification.fireDate = newDate
        if timeBefore == 0 {
          notification.alertBody = Text.take(line: departure.line.code,
                                             to: departure.line.destination)
        } else {
          notification.alertBody = Text.take(line: departure.line.code,
                                             to: departure.line.destination,
                                             in: timeBefore)
        }
        notification.identifier = "departureNotification-\(String.random(30))"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
      }
    }
  }
}

extension DetailDeparturesViewController: UITableViewDelegate,
                                          UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return busRouteGroup?.steps.count ?? 0
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "busRouteCell",
      for: indexPath)
      as? BusRouteTableViewCell else {
        return UITableViewCell()
    }

    guard let stop = App.stops.filter({
      $0.code == busRouteGroup!.steps[indexPath.row].stop.code
    })[safe: 0]
      else { return UITableViewCell() }

    cell.configure(with: busRouteGroup!.steps[indexPath.row],
                   color: LineColorManager.color(for: busRouteGroup!.lineCode),
                   selected: titleSelected == stop.name)

    return cell
  }

  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }

  func tableView(_ tableView: UITableView,
                 canEditRowAt indexPath: IndexPath) -> Bool {
    return busRouteGroup!.steps[indexPath.row].arrivalTime != ""
  }

  func tableView(_ tableView: UITableView,
                 editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    // swiftlint:disable:previous line_length
    let reminderAction = UITableViewRowAction(style: .normal,
                                              title: Text.reminder) { (_, _) in
      App.log("Departures: Reminder")
      let leftTime = Int(self.busRouteGroup!.steps[indexPath.row].arrivalTime) ?? -1
      let alertMessage = Text.reminderMessage(stopName: self.stop?.name ?? "??",
                                              leftTime: "\(leftTime)")
      var alertController = UIAlertController(title: "Reminder".localized,
                                              message: alertMessage,
                                              preferredStyle: .alert)
      if leftTime < 0 {
        alertController.title = Text.busIsComming
        alertController.message = Text.cantSetATimer
      } else {
        let departureTimeAction = UIAlertAction(title: Text.atDepartureTime,
                                                style: .default) { _ in
         let step = self.busRouteGroup!.steps[indexPath.row]
         self.setAlert(with: 0,
                      date: step.timestamp,
                      fromName: step.stop.name,
                      fromCode: step.stop.code)
        }
        alertController.addAction(departureTimeAction)

        if leftTime > 5 {
          let fiveMinutesBeforeAction = UIAlertAction(title: Text.fiveMinutesBefore,
                                                      style: .default) { _ in
            let step = self.busRouteGroup!.steps[indexPath.row]
            self.setAlert(with: 5,
                          date: step.timestamp,
                          fromName: step.stop.name,
                          fromCode: step.stop.code)
          }
          alertController.addAction(fiveMinutesBeforeAction)
        }
        if leftTime > 10 {
          let tenMinutesBeforeAction = UIAlertAction(title: Text.tenMinutesBefore,
                                                     style: .default) { _ in
            let step = self.busRouteGroup!.steps[indexPath.row]
            self.setAlert(with: 10,
                          date: step.timestamp,
                          fromName: step.stop.name,
                          fromCode: step.stop.code)
          }
          alertController.addAction(tenMinutesBeforeAction)
        }

        let otherAction = UIAlertAction(title: Text.other, style: .default) { _ in
          alertController.dismiss(animated: true, completion: nil)
          alertController = UIAlertController(title: Text.reminder,
                                              message: Text.whenReminder,
                                              preferredStyle: .alert)

          alertController.addTextField { textField in
            textField.placeholder = Text.numberMinutesBeforeDepartures
            textField.keyboardType = .numberPad
            textField.keyboardAppearance = App.darkMode ? .dark : .light
          }

          let okAction = UIAlertAction(title: Text.ok,
                                       style: .default) { _ in
            guard let text = alertController.textFields?[0].text else { return }
            guard let remainingTime = Int(text) else { return }
            let step = self.busRouteGroup!.steps[indexPath.row]
            self.setAlert(with: remainingTime,
                          date: step.timestamp,
                          fromName: step.stop.name,
                          fromCode: step.stop.code)
          }
          alertController.addAction(okAction)

          let cancelAction = UIAlertAction(title: Text.cancel,
                                           style: .destructive) { _ in }
          alertController.addAction(cancelAction)

          self.present(alertController, animated: true, completion: nil)
        }

        alertController.addAction(otherAction)
      }

      let cancelAction = UIAlertAction(title: Text.cancel,
                                       style: .destructive) { _ in }
      alertController.addAction(cancelAction)

      self.present(alertController, animated: true, completion: nil)
    }
    if App.darkMode {
      reminderAction.backgroundColor = .black
    } else {
      reminderAction.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
    }
    return [reminderAction]
  }
}

extension DetailDeparturesViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    if let annotation = annotation as? MGLPolyline {
      if (annotation.title ?? "") == Text.passedStops {
        return .gray
      } else {
        return self.color ?? .black
      }
    }
    return .black
  }

  func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
    if let titleSelected = (annotationView.annotation?.title ?? ""),
      let index = self.names.index(of: titleSelected) {
      self.tableView.scrollToRow(at: IndexPath(row: index, section: 0),
                                 at: .top,
                                 animated: true)
    }
  }
  
  func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
    titleSelected = ""
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    if annotation is MGLPolyline {
      return false
    } else {
      return true
    }
  }
}

extension DetailDeparturesViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
    // swiftlint:disable:previous line_length
    controller.dismiss(animated: true, completion: nil)
  }
}

extension DetailDeparturesViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    // swiftlint:disable:previous line_length

    guard let indexPath = tableView.indexPathForRow(at: location)
      else { return nil }

    guard let row = tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell
      else { return nil }

    let viewControllerId = "departuresViewController"
    guard let detailVC =
      storyboard?.instantiateViewController(withIdentifier: viewControllerId)
        as? DeparturesViewController else { return nil }

    detailVC.stop = App.stops.filter({ $0.code == row.busRoute?.stop.code })[safe: 0]
    previewingContext.sourceRect = row.frame
    return detailVC
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
}
