//
//  BusRouteViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 20/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

class BusRouteViewController: ScrollViewController {
  
  var departure: Departure!
  var stop: Stop!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet weak var reloadImageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.reload()
  }
  
  @IBAction func reload() {
    self.stackView.subviews.forEach({ $0.removeFromSuperview() })
    reloadImageView.image = nil
    activityIndicatorView.isHidden = false
    if departure.offline {
      let departures = TimetablesManager.shared.offlineDepartures(tripId: departure.vehiculeNo)
      let dateFormatter = DateFormatter()
      dateFormatter.timeStyle = .short
      dateFormatter.timeZone = Calendar.current.timeZone
      dateFormatter.dateStyle = .none
      
      for (index, x) in departures.enumerated() {
        let isPassed = (Int(x.leftTime) ?? 0) < 0
        let color = isPassed ? .gray : LineColorManager.color(for: x.line.code)
        
        if index == 0 {
          let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
          routePreviewRow.lineLabel.text = x.line.code
          routePreviewRow.lineLabel.textColor = color.contrast
          routePreviewRow.lineBackgroundView.backgroundColor = color
          routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathStart").colorize(with: color)
          routePreviewRow.directionLabel.text = "Direction \(departures.last?.line.destination ?? "")"
          routePreviewRow.hourLabel.text = isPassed ? "" : "\(x.leftTime)'"
          routePreviewRow.hourLabel.textColor = App.textColor
          routePreviewRow.stopNameLabel.text = App.stops.first(where: { $0.sbbId == String(x.stop!) })?.name ?? ""
          routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
          routePreviewRow.directionLabel.textColor = isPassed ? .gray : App.textColor
          self.stackView.addArrangedSubview(routePreviewRow)
        }
        
        let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
        routePreviewRow.lineBackgroundView.isHidden = true
        routePreviewRow.directionLabel.isHidden = true
        
        if index == departures.endIndex {
          routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathEnd").colorize(with: color)
        } else {
          routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathMiddle").colorize(with: color)
        }
        
        routePreviewRow.hourLabel.text = isPassed ? "" : "\(x.leftTime)'"
        routePreviewRow.hourLabel.textColor = App.textColor
        routePreviewRow.stopNameLabel.text = App.stops.first(where: { $0.sbbId == String(x.stop!) })?.name ?? ""
        routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
        routePreviewRow.stopNameLabel.numberOfLines = 0
        
        self.stackView.addArrangedSubview(routePreviewRow)
      }
      let stops = departures.compactMap { (departure) -> Stop? in
        App.stops.first(where: { (stop) -> Bool in
          stop.sbbId == "\(departure.stop ?? 0)"
        })
      }
      let centerTo = App.stops.first(where: { (stop) -> Bool in
        stop.appId == (departures.first(where: { $0.leftTime != "" }) ?? departures.last!).stop
      })?.location
      MapManager.shared.showPath(stops: stops, color: LineColorManager.color(for: departures.first?.line.code ?? ""), centerTo: centerTo)
      activityIndicatorView.isHidden = true
      reloadImageView.image = #imageLiteral(resourceName: "refresh")
    } else {
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
            let busRouteGroup = try? jsonDecoder.decode(BusRouteGroup.self, from: data)
            
            for (index, step) in (busRouteGroup?.steps ?? []).enumerated() {
              let isPassed = (step.arrivalTime == "")
              let color = isPassed ? .gray : LineColorManager.color(for: self.departure.line.code)
              
              if index == 0 {
                let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
                routePreviewRow.lineLabel.text = self.departure.line.code
                routePreviewRow.lineLabel.textColor = color.contrast
                routePreviewRow.lineBackgroundView.backgroundColor = color
                routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathStart").colorize(with: color)
                routePreviewRow.directionLabel.text = "Direction \((busRouteGroup?.steps ?? []).last?.stop.name ?? "")"
                routePreviewRow.hourLabel.text = isPassed ? "" : "\(step.arrivalTime)'"
                routePreviewRow.hourLabel.textColor = App.textColor
                routePreviewRow.stopNameLabel.text = step.stop.name
                routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
                routePreviewRow.directionLabel.textColor = isPassed ? .gray : App.textColor
                routePreviewRow.stopNameLabel.numberOfLines = 1
                routePreviewRow.directionLabel.numberOfLines = 1
                self.stackView.addArrangedSubview(routePreviewRow)
                continue
              }
              
              let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
              routePreviewRow.lineBackgroundView.isHidden = true
              routePreviewRow.directionLabel.isHidden = true
              
              if index == (busRouteGroup?.steps ?? []).endIndex - 1 {
                routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathEnd").colorize(with: color)
              } else {
                routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathMiddle").colorize(with: color)
              }
              
              routePreviewRow.hourLabel.text = isPassed ? "" : "\(step.arrivalTime)'"
              routePreviewRow.hourLabel.textColor = App.textColor
              routePreviewRow.stopNameLabel.text = step.stop.name
              routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
              routePreviewRow.stopNameLabel.numberOfLines = 0
              
              self.stackView.addArrangedSubview(routePreviewRow)
            }
            self.activityIndicatorView.isHidden = true
            self.reloadImageView.image = #imageLiteral(resourceName: "refresh")
            
            let stops = (busRouteGroup?.steps ?? []).compactMap { (departure) -> Stop? in
              App.stops.first(where: { (stop) -> Bool in
                stop.code == departure.stop.code
              })
            }
            let centerTo = App.stops.first(where: { (stop) -> Bool in
              stop.code == (busRouteGroup?.steps.first(where: { $0.arrivalTime != "" }) ?? busRouteGroup?.steps.last)?.stop.code
            })?.location
            MapManager.shared.showPath(stops: stops, color: LineColorManager.color(for: self.departure.line.code), centerTo: centerTo)
          }
      }
    }
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
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) {(accepted, _) in
          if !accepted {
            print("Notification access denied.")
          }
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
    }
  }
}
