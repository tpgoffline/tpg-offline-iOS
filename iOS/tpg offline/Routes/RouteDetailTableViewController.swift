//
//  RouteDetailTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import UserNotifications
import SCLAlertView

class RouteDetailTableViewController: UITableViewController {

    var actualRoute = 0
    let defaults = UserDefaults.standard
    var favorite = false

    override func viewDidLoad() {
        super.viewDidLoad()

        var itemsList: [UIBarButtonItem] = []

        for x in AppValues.favoritesRoutes where x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                favorite = true
                break
        }
        if favorite {
            itemsList.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starNavbar").maskWithColor(color: AppValues.textColor).withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.done, target: self, action: #selector(RouteDetailTableViewController.toggleFavorite(_:))))
        } else {
            itemsList.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starEmptyNavbar").maskWithColor(color: AppValues.textColor).withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.done, target: self, action: #selector(RouteDetailTableViewController.toggleFavorite(_:))))
        }
        self.navigationItem.rightBarButtonItems = itemsList
        tableView.backgroundColor = AppValues.primaryColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshTheme()
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActualRoutes.routeResult[actualRoute].connections.count
    }

    func labelToImage(_ label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itineraireCell", for: indexPath) as! DetailRouteTableViewCell // swiftlint:disable:this force_cast

        var textColor = UIColor.white

        if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].transportCategory != .walk {

            if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].isSBB {
                cell.lineLabel.text = "Train ".localized + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
            } else {
                cell.lineLabel.text = "Ligne ".localized + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
            }

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)

                if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].isTpg {
                    cell.backgroundColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]
                    textColor = AppValues.linesColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!

                    let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                    labelPictoLigne.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
                    labelPictoLigne.textAlignment = .center
                    labelPictoLigne.textColor = textColor
                    labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                    labelPictoLigne.layer.borderColor = textColor.cgColor
                    labelPictoLigne.layer.borderWidth = 1
                    let image = labelToImage(labelPictoLigne)
                    for x in cell.iconImageView.constraints where x.identifier == "iconeImageViewHeight" {
                            x.constant = 24
                        }
                    cell.iconImageView.image = image
                } else {
                    cell.iconImageView.image = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].image.maskWithColor(color: .white)
                    for x in cell.iconImageView.constraints where x.identifier == "iconeImageViewHeight" {
                            x.constant = 42
                    }
                }
                cell.directionImageView.image = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].image.maskWithColor(color: textColor)
                cell.directionLabel.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].direction
            } else {
                textColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                cell.backgroundColor = .white

                if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].isTpg {
                    cell.backgroundColor = .white

                    let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                    labelPictoLigne.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
                    labelPictoLigne.textAlignment = .center
                    labelPictoLigne.textColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line] ?? AppValues.textColor
                    labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                    labelPictoLigne.layer.borderColor = (AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line] ?? AppValues.textColor).cgColor
                    labelPictoLigne.layer.borderWidth = 1

                    textColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line] ?? AppValues.textColor

                    if AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]?.contrast == .white {
                        textColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!
                    } else {
                        textColor = textColor.darken(percentage: 0.2)!
                        labelPictoLigne.textColor = labelPictoLigne.textColor.darken(percentage: 0.2)
                        labelPictoLigne.layer.borderColor = UIColor(cgColor: labelPictoLigne.layer.borderColor!).darken(percentage: 0.2)?.cgColor
                    }

                    let image = labelToImage(labelPictoLigne)
                    cell.iconImageView.image = image
                    for x in cell.iconImageView.constraints where x.identifier == "iconeImageViewHeight" {
                            x.constant = 24
                    }
                } else {
                    cell.iconImageView.image = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].image.maskWithColor(color: textColor)
                }
                cell.directionImageView.image = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].image.maskWithColor(color: textColor)
                cell.directionLabel.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].direction
            }
        } else {
            cell.backgroundColor = AppValues.primaryColor
            textColor = AppValues.textColor

            cell.departureLabel.text = ""
            cell.hourDepartureLabel.text = ""
            cell.arrivalLabel.text = ""
            cell.hourArrivalLabel.text = ""

            cell.iconImageView.image = #imageLiteral(resourceName: "walking").maskWithColor(color: AppValues.textColor)
            cell.directionImageView.image = #imageLiteral(resourceName: "walking").maskWithColor(color: AppValues.textColor)
            cell.lineLabel.text = "Marche".localized
            cell.directionLabel.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].direction

        }

        cell.lineLabel.textColor = textColor
        cell.directionLabel.textColor = textColor
        cell.departureLabel.textColor = textColor
        cell.hourDepartureLabel.textColor = textColor
        cell.arrivalLabel.textColor = textColor
        cell.hourArrivalLabel.textColor = textColor

        cell.departureImageView.image = #imageLiteral(resourceName: "logOut").maskWithColor(color: textColor)
        cell.departureLabel.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].from

        var timestamp = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].departureTimestamp
        cell.hourDepartureLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(timestamp)), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)

        timestamp = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].arrivalTimestamp
        cell.hourArrivalLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(timestamp)), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)

        cell.arrivalImageView.image = #imageLiteral(resourceName: "logIn").maskWithColor(color: textColor)
        cell.arrivalLabel.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].to

        return cell
    }

    func toggleFavorite(_ sender: Any!) {
        if AppValues.favoritesRoutes.isEmpty {
            AppValues.favoritesRoutes = [[ActualRoutes.route.departure!, ActualRoutes.route.arrival!]]
        } else {
            if self.favorite {
                AppValues.favoritesRoutes = AppValues.favoritesRoutes.filter({ (arretA) -> Bool in
                    if arretA[0].fullName == ActualRoutes.route.departure?.fullName && arretA[1].fullName == ActualRoutes.route.arrival?.fullName {
                        return false
                    }
                    return true
                })
            } else {
                AppValues.favoritesRoutes.append([ActualRoutes.route.departure!, ActualRoutes.route.arrival!])
            }
        }

        self.favorite = !self.favorite

        let encodedData = NSKeyedArchiver.archivedData(withRootObject: AppValues.favoritesRoutes)
        defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesRoutes.rawValue)

        var listeItems: [UIBarButtonItem] = []
        var favoris = false
        for x in AppValues.favoritesRoutes where x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                favoris = true
                break
        }
        if favoris {
            listeItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starNavbar").withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.done, target: self, action:#selector(RouteDetailTableViewController.toggleFavorite(_:))))
        } else {
            listeItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starEmptyNavbar").withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.done, target: self, action: #selector(RouteDetailTableViewController.toggleFavorite(_:))))
        }
        self.navigationItem.rightBarButtonItems = listeItems
        guard let navController = self.splitViewController?.viewControllers[0] as? UINavigationController else {
            return
        }
        guard let routesViewController = navController.viewControllers[0] as? RoutesCollectionViewController else {
            return
        }
        routesViewController.collectionView?.reloadData()
    }

    func scheduleNotification(_ time: Date, before: Int = 5, ligne: String, direction: String, arretDescente: String) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    let content = UNMutableNotificationContent()
                    if before == 0 {
                        content.title = "Départ immédiat !".localized
                        content.body = "Le tpg de la ligne ".localized + ligne + " en direction de ".localized + direction + " va partir immédiatement. ".localized + "Descendez à ".localized + String(arretDescente)
                    } else {
                        content.title = "Départ dans ".localized + String(before) + " minutes".localized
                        var text =  "Le tpg de la ligne ".localized
                        text += ligne
                        text += " en direction de ".localized
                        text += direction
                        text += " va partir dans ".localized
                        text += String(before)
                        text += " minutes. ".localized
                        text += "Descendez à ".localized
                        text += String(arretDescente)
                        content.body = text
                    }
                    content.categoryIdentifier = "departureNotifications"
                    content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
                    content.userInfo = [:]
                    content.sound = UNNotificationSound.default()

                    let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time.addingTimeInterval(Double(before * 60) * -1))
                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: time)

                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!), repeats: false)

                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in
                        DispatchQueue.main.sync {
                            if error == nil {
                                let okView = SCLAlertView()
                                if before == 0 {
                                    okView.showSuccess("Vous serez notifié".localized, subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized, closeButtonTitle: "OK", duration: 10, feedbackType: .notificationSuccess)
                                } else {
                                    var texte =  "La notification à été enregistrée et sera affichée ".localized
                                    texte += String(before)
                                    texte += " minutes avant le départ.".localized
                                    okView.showSuccess("Vous serez notifié".localized, subTitle: texte, closeButtonTitle: "OK", duration: 10, feedbackType: .notificationSuccess)
                                }
                            } else {
                                let alertView = SCLAlertView()
                                alertView.showError("Impossible d'enregistrer la notification", subTitle: "L'erreur a été reportée au développeur. Merci de réessayer.", closeButtonTitle: "OK", duration: 30, feedbackType: .notificationError)
                            }
                        }
                    })
                } else {
                    let alertView = SCLAlertView()
                    alertView.showError("Notifications désactivées", subTitle: "Merci d'activer les notifications dans les réglages", closeButtonTitle: "OK", duration: 30, feedbackType: .notificationError)
                }
            }
        } else {
            let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time.addingTimeInterval(Double(before * 60) * -1))

            let cal = Calendar(identifier: Calendar.Identifier.gregorian)

            let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: time)
            let reminder = UILocalNotification()
            reminder.fireDate = date

            var texte =  "Le tpg de la ligne ".localized
            texte += ligne
            texte += " en direction de ".localized
            texte += direction
            if before == 0 {
                texte += " va partir immédiatement. ".localized
            } else {
                texte += " va partir dans ".localized
                texte += String(before)
                texte += " minutes. ".localized
            }
            texte += "Descendez à ".localized
            texte += String(arretDescente)
            reminder.alertBody = texte
            reminder.soundName = UILocalNotificationDefaultSoundName

            UIApplication.shared.scheduleLocalNotification(reminder)

            print("Firing at \(String(describing: now.hour)):\(now.minute! - before):\(String(describing: now.second))")

            let okView = SCLAlertView()
            if before == 0 {
                okView.showSuccess("Vous serez notifié".localized, subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized, closeButtonTitle: "OK".localized, duration: 10, feedbackType: .notificationSuccess)
            } else {
                var texte = "La notification à été enregistrée et sera affichée ".localized
                texte += String(before)
                texte += " minutes avant le départ.".localized
                okView.showSuccess("Vous serez notifié".localized, subTitle: texte, closeButtonTitle: "OK".localized, duration: 10, feedbackType: .notificationSuccess)
            }
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let time = Date(timeIntervalSince1970: Double(ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].departureTimestamp)).timeIntervalSince(Date())
        let timerAction = UITableViewRowAction(style: .default, title: "Rappeler".localized) { (action, indexPath) in
            let alertView = SCLAlertView()
            if time < 60 {
                alertView.showWarning("Le bus arrive".localized, subTitle: "Dépêchez vous, vous allez le rater !".localized, closeButtonTitle: "OK".localized, duration: 10, feedbackType: .notificationWarning)
            } else {
                alertView.addButton("A l'heure du départ".localized, action: { () -> Void in
                    self.scheduleNotification(Date(timeIntervalSinceNow: time), before: 0, ligne: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].line, direction: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].direction, arretDescente: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].to)
                })
                if time > 60 * 5 {
                    alertView.addButton("5 min avant le départ".localized, action: { () -> Void in
                        self.scheduleNotification(Date(timeIntervalSinceNow: time), before: 5, ligne: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].line, direction: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].direction, arretDescente: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].to)
                    })
                }
                if time > 60 * 10 {
                    alertView.addButton("10 min avant le départ".localized, action: { () -> Void in
                        self.scheduleNotification(Date(timeIntervalSinceNow: time), before: 10, ligne: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].line, direction: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].direction, arretDescente: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].to)
                    })
                }
                alertView.addButton("Autre", action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombre de minutes".localized)
                    txt.keyboardType = .numberPad
                    txt.becomeFirstResponder()
                    customValueAlert.addButton("Rappeler".localized, action: { () -> Void in
                        if Int(time) < Int(txt.text!)! * 60 {
                            customValueAlert.hideView()
                            let alertView = SCLAlertView()
                            alertView.showError("Il y a un problème".localized, subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized, closeButtonTitle: "OK", duration: 10, feedbackType: .notificationError)

                        } else {
                            self.scheduleNotification(Date(timeIntervalSinceNow: time), before: Int(txt.text!)!, ligne: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].line, direction: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].direction, arretDescente: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].to)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: #imageLiteral(resourceName: "clock").maskWithColor(color: .white))
                })
                alertView.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: #imageLiteral(resourceName: "clock").maskWithColor(color: .white))
                tableView.setEditing(false, animated: true)
            }

        }
        timerAction.backgroundColor = .flatBlue
        return [timerAction]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
