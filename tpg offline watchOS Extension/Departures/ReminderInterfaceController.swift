//
//  ReminderInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 06/04/2018.
//  Copyright © 2018 Remy. All rights reserved.
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
        if crownRotationalDelta > expectedMoveDelta { //Crown rotating in clock-wise direction
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

    func setAlert(with timeBefore: Int, departure: Departure, forceDisableSmartReminders: Bool = false) {
        var departure = departure
        departure.calculateLeftTime()
        let date = departure.dateCompenents?.date?.addingTimeInterval(TimeInterval(timeBefore * -60))
        let components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: date ?? Date())
        let stop = DeparturesManager.shared.stop

        if App.smartReminders, !forceDisableSmartReminders, departure.code != -1, let stopCode = stop?.code {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            var parameters: Parameters = [
                "device": App.apnsToken,
                "departureCode": departure.code,
                "title": timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)"),
                "text": String(format: "Take the line %@ to %@".localized,
                               "\(departure.line.code)", "\(departure.line.destination)"),
                "line": departure.line.code,
                "reminderTimeBeforeDeparture": timeBefore,
                "stopCode": stopCode,
                "estimatedArrivalTime": formatter.string(from: Calendar.current.date(from: departure.dateCompenents!)!),
                "sandbox": false
            ]
            #if DEBUG
            parameters["sandbox"] = true
            #endif
            Alamofire.request("https://tpgoffline-apns.alwaysdata.net/reminders/add", method: .post, parameters: parameters).responseString(completionHandler: { (response) in
                dump(response)
                if let string = response.result.value, string == "1" {
                    let action = WKAlertAction(title: "OK", style: .default, handler: {
                        self.dismiss()
                    })
                    self.presentAlert(withTitle: "You will be reminded".localized,
                                      message: String(format: "A notification will be send %@".localized,
                                                      (timeBefore == 0 ? "at the time of departure.".localized :
                                                        String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                      preferredStyle: .alert, actions: [action])
                } else if let string = response.result.value, string == "0" {
                    let action = WKAlertAction(title: "OK", style: .default, handler: {})
                    self.presentAlert(withTitle: "Duplicated reminder".localized,
                                      message: "We already sheduled a reminder with these parameters.".localized,
                                      preferredStyle: .alert, actions: [action])
                } else {
                    let tryAgainAction = WKAlertAction(title: "Try again", style: .default, handler: {
                        self.setAlert(with: timeBefore, departure: departure, forceDisableSmartReminders: false)
                    })
                    let tryAgainWithoutSmartAction = WKAlertAction(title: "Try again without Smart Reminders", style: .default, handler: {
                        self.setAlert(with: timeBefore, departure: departure, forceDisableSmartReminders: true)
                    })
                    let cancelAction = WKAlertAction(title: "Cancel", style: .default, handler: {
                        self.dismiss()
                    })
                    self.presentAlert(withTitle: "Error".localized,
                                      message: "Sorry, but we were not able to add your smart notification. Do you want to try again?".localized,
                                      preferredStyle: .alert, actions: [tryAgainAction, tryAgainWithoutSmartAction, cancelAction])
                }
            })
        } else {
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let content = UNMutableNotificationContent()

            content.title = timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)")
            content.body = String(format: "Take the line %@ to %@".localized,
                                  "\(departure.line.code)", "\(departure.line.destination)")
            content.sound = UNNotificationSound.default()
            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            let request = UNNotificationRequest(identifier: "departureNotification-\(String.random(30))", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {(error) in
                if let error = error {
                    print("Uh oh! We had an error: \(error)")
                    let action = WKAlertAction(title: "OK", style: .default, handler: {})
                    self.presentAlert(withTitle: "An error occurred".localized,
                                      message: "Sorry for that. Can you try again, or send an email to us if the problem persist?".localized,
                                      preferredStyle: .alert, actions: [action])
                } else {
                    let action = WKAlertAction(title: "OK", style: .default, handler: {
                        self.dismiss()
                    })
                    self.presentAlert(withTitle: "You will be reminded".localized,
                                      message: String(format: "A notification will be send %@".localized,
                                                      (timeBefore == 0 ? "at the time of departure.".localized :
                                                        String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                      preferredStyle: .alert, actions: [action])
                }
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
