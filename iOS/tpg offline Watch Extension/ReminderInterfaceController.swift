//
//  ReminderInterfaceController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 26/10/2016.
//  Copyright © 2016 Rémy DA COSTA FARO. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

class ReminderInterfaceController: WKInterfaceController {

    var value = 0.0
    @IBOutlet weak var picker: WKInterfacePicker!
    var departure: Departures?
    var itemList: [(String, String)] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard let departure = context as? Departures else {
            let okAction = WKAlertAction(title: "OK", style: .default) {
                self.pop()
            }
            self.presentAlert(withTitle: NSLocalizedString("Désolé", comment: ""), message: NSLocalizedString("Il n'y a plus de bus pour cette ligne.", comment: ""), preferredStyle: .alert, actions: [okAction])
            return
        }

        if Int(departure.leftTime) == 0 {
            let okAction = WKAlertAction(title: "OK", style: .default) {
                self.pop()
            }
            self.presentAlert(withTitle: NSLocalizedString("Le bus arrive", comment: ""), message: NSLocalizedString("Dépêchez vous, vous allez le rater !", comment: ""), preferredStyle: .alert, actions: [okAction])
        } else {

            var max = 60
            if Int(departure.leftTime)! < 60 {
                max = Int(departure.leftTime)! - 1
            }

            for x in 0...max {
                itemList.append((String(x), String(x)))
            }

            let pickerItems: [WKPickerItem] = itemList.map {
                let pickerItem = WKPickerItem()
                pickerItem.caption = $0.0
                pickerItem.title = $0.1
                return pickerItem
            }
            picker.setItems(pickerItems)
            picker.focus()
        }
    }

    @IBAction func pickerChanged(value: Int) {
        self.value = Double(itemList[value].1)!
    }

    @IBAction func setReminder() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                let content = UNMutableNotificationContent()
                if Int(self.value) == 0 {
                    content.title = NSLocalizedString("Départ immédiat !", comment: "")
                    var text = ""
                    text += NSLocalizedString("Le tpg de la line ", comment: "")
                    text += self.departure!.line
                    text += NSLocalizedString(" en direction de ", comment: "")
                    text += self.departure!.direction
                    text += NSLocalizedString(" va partir immédiatement", comment: "")
                    content.body = text
                } else {
                    content.title = NSLocalizedString("Départ dans ", comment: "") + String(Int(self.value))  + NSLocalizedString(" minutes", comment: "")
                    var text =  NSLocalizedString("Le tpg de la line ", comment: "")
                    text += self.departure!.line
                    text += NSLocalizedString(" en direction de ", comment: "")
                    text += self.departure!.direction
                    text += NSLocalizedString(" va partir dans ", comment: "")
                    text += String(Int(self.value))
                    text += NSLocalizedString(" minutes", comment: "")
                    content.body = text
                }
                content.categoryIdentifier = "departureNotifications"
                content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
                content.userInfo = [:]
                content.sound = UNNotificationSound.default()

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                var time = dateFormatter.date(from: self.departure!.timestamp)
                time!.addTimeInterval(self.value * -60)
                let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)

                let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())

                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!), repeats: false)

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { (error) in
                    DispatchQueue.main.sync {
                        if error == nil {
                            if Int(self.value) == 0 {
                                let okAction = WKAlertAction(title: "OK", style: .default) {
                                    DispatchQueue.main.sync {
                                        self.pop()
                                    }
                                }
                                self.presentAlert(withTitle: NSLocalizedString("Vous serez notifié", comment: ""), message: NSLocalizedString("La notification à été enregistrée et sera affichée à l'heure du départ.", comment: ""), preferredStyle: .alert, actions: [okAction])
                            } else {
                                var texte =  NSLocalizedString("La notification à été enregistrée et sera affichée ", comment: "")
                                texte += String(Int(self.value))
                                texte += NSLocalizedString(" minutes avant le départ.", comment: "")
                                let okAction = WKAlertAction(title: "OK", style: .default) {
                                    DispatchQueue.main.sync {
                                        self.pop()
                                    }
                                }
                                self.presentAlert(withTitle: NSLocalizedString("Vous serez notifié", comment: ""), message: texte, preferredStyle: .alert, actions: [okAction])
                            }
                        } else {
                            let okAction = WKAlertAction(title: "OK", style: .default) {
                                DispatchQueue.main.sync {
                                    self.pop()
                                }
                            }
                            self.presentAlert(withTitle: NSLocalizedString("Impossible d'enregistrer la notification", comment: ""), message: NSLocalizedString("L'erreur a été reportée au développeur. Merci de réessayer.", comment: ""), preferredStyle: .alert, actions: [okAction])
                        }
                    }
                })
            } else {
                let okAction = WKAlertAction(title: "OK", style: .default) {
                    DispatchQueue.main.sync {
                        self.pop()
                    }
                }
                self.presentAlert(withTitle: NSLocalizedString("Notifications désactivées", comment: ""), message: NSLocalizedString("Merci d'activer les notifications dans les réglages", comment: ""), preferredStyle: .alert, actions: [okAction])
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
