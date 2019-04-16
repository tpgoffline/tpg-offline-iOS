//
//  ReminderInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 06/04/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import UserNotifications

class ReminderInterfaceController: WKInterfaceController, WKCrownDelegate {
  
  @IBOutlet weak var beforeTimeImageView: WKInterfaceImage!
  
  var minutesBeforeDeparture = 10
  let expectedMoveDelta = 0.2617995
  var crownRotationalDelta = 0.0
  var departure: Departure?
  var maximum = 60
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    guard let option = context as? Departure else {
      print("Context is not in a valid format")
      return
    }
    departure = option
    if Int(departure?.leftTime ?? "") ?? 0 < 60 {
      maximum = Int(departure?.leftTime ?? "") ?? 0
    }
    if let leftTime = departure?.leftTime, Int(leftTime) ?? 0 < 10 {
      beforeTimeImageView.setImageNamed("reminderCircle-\(leftTime)")
    }
    crownSequencer.delegate = self
    crownSequencer.focus()
  }
  
  override func willActivate() {
    super.willActivate()
    crownSequencer.focus()
  }
  
  func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
    crownRotationalDelta  += rotationalDelta
    if crownRotationalDelta > expectedMoveDelta {
      let newValue = minutesBeforeDeparture + 1
      if newValue < 0 {
        minutesBeforeDeparture = 0
      } else if newValue > maximum {
        minutesBeforeDeparture = maximum
      } else {
        minutesBeforeDeparture = newValue
      }
      beforeTimeImageView.setImageNamed("reminderCircle-\(minutesBeforeDeparture)")
      crownRotationalDelta = 0.0
    } else if crownRotationalDelta < -expectedMoveDelta {
      let newValue = minutesBeforeDeparture - 1
      if newValue < 0 {
        minutesBeforeDeparture = 0
      } else if newValue > maximum {
        minutesBeforeDeparture = maximum
      } else {
        minutesBeforeDeparture = newValue
      }
      beforeTimeImageView.setImageNamed("reminderCircle-\(minutesBeforeDeparture)")
      crownRotationalDelta = 0.0
    }
  }
  
  @IBAction func setReminder() {
    guard let departure = self.departure else { return }
    setAlert(with: minutesBeforeDeparture, departure: departure)
  }
  
  func setAlert(with timeBefore: Int,
                departure: Departure,
                forceDisableSmartReminders: Bool = false) {
    var departure = departure
    departure.calculateLeftTime()
    let date = departure.dateCompenents?.date?
      .addingTimeInterval(TimeInterval(timeBefore * -60))
    let components = Calendar.current.dateComponents([.hour,
                                                      .minute,
                                                      .day,
                                                      .month,
                                                      .year],
                                                     from: date ?? Date())
    let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                repeats: false)
    let content = UNMutableNotificationContent()
    
    content.title = timeBefore == 0 ?
      Text.busIsCommingNow : Text.minutesLeft(timeBefore)
    content.body = Text.take(line: departure.line.code,
                             to: departure.line.destination)
    content.sound = UNNotificationSound.default
    let request =
      UNNotificationRequest(identifier:
        "departureNotification-\(String.random(30))",
        content: content,
        trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error) in
      if let error = error {
        print("Uh oh! We had an error: \(error)")
        let action = WKAlertAction(title: Text.ok, style: .default, handler: {})
        self.presentAlert(withTitle: Text.error,
                          message: Text.sorryError,
                          preferredStyle: .alert, actions: [action])
      } else {
        let action = WKAlertAction(title: Text.ok, style: .default, handler: {
          self.dismiss()
        })
        self.presentAlert(
          withTitle: Text.youWillBeReminded,
          message: Text.notificationWillBeSend(minutes: timeBefore),
          preferredStyle: .alert,
          actions: [action])
      }
    }
  }
}
