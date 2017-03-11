//
//  RoutesListTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import FirebaseCrash
import FirebaseAnalytics
import SCLAlertView
import SwiftyJSON

class RoutesListTableViewController: UITableViewController {

    let defaults = UserDefaults.standard
    var favorite = false
    var noNetwork = false
    var loading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        FIRCrashMessage(ActualRoutes.route.describe())
        #if DEBUG
        #else
            FIRAnalytics.logEvent(withName: "departure", parameters: [
                "departure": (ActualRoutes.route.departure?.stopCode ?? "XXXX") as NSObject,
                "arrival": (ActualRoutes.route.arrival?.stopCode ?? "XXXX") as NSObject
                ])
        #endif

        ActualRoutes.routeResult = []
        tableView.backgroundColor = AppValues.primaryColor

        if ActualRoutes.route.departure != nil && ActualRoutes.route.arrival != nil && ActualRoutes.route.date != nil {
            loading = true
            refresh()
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()

        tableView.backgroundColor = AppValues.primaryColor

        if ActualRoutes.route.departure != nil && ActualRoutes.route.arrival != nil && ActualRoutes.route.date != nil {
            var listeItems: [UIBarButtonItem] = []

            for x in AppValues.favoritesRoutes {
                if x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                    favorite = true
                    break
                }
            }
            if favorite {
                listeItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starNavbar"), style: .done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
            } else {
                listeItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starEmptyNavbar"), style: .done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
            }
            self.navigationItem.rightBarButtonItems = listeItems
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true {
            return 1
        } else if ActualRoutes.route == nil {
            return 0
        } else if ActualRoutes.route.departure == nil || ActualRoutes.route.arrival == nil || ActualRoutes.route.date == nil {
            return 0
        } else if noNetwork {
            return 1
        } else if ActualRoutes.routeResult.count == 0 {
            return 1
        } else {
            return ActualRoutes.routeResult.count
        }
    }

    func refresh() {
        self.loading = true
        self.tableView.reloadData()
        var parameters: [String:Any] = [:]
        parameters["from"] = ActualRoutes.route.departure!.transportAPIiD
        parameters["to"] = ActualRoutes.route.arrival!.transportAPIiD
        parameters["date"] = String(describing: ActualRoutes.route.date!.year!) + "-" + String(describing: ActualRoutes.route.date!.month!) + "-" + String(describing: ActualRoutes.route.date!.day!)
        parameters["time"] = String(describing: ActualRoutes.route.date!.hour!) + ":" + String(describing: ActualRoutes.route.date!.minute!)
        parameters["isArrivalTime"] = String(describing: ActualRoutes.route.isArrivalDate.hashValue)
        parameters["fields"] = [
            "connections/duration",
            "connections/from/station/id",
            "connections/from/station/name",
            "connections/from/departureTimestamp",
            "connections/to/station/id",
            "connections/to/station/name",
            "connections/to/arrivalTimestamp",
            "connections/sections/walk",
            "connections/sections/journey/name",
            "connections/sections/journey/operator",
            "connections/sections/journey/categoryCode",
            "connections/sections/journey/walk/duration",
            "connections/sections/journey/to",
            "connections/sections/departure/station/name",
            "connections/sections/departure/station/id",
            "connections/sections/departure/departureTimestamp",
            "connections/sections/arrival/station/name",
            "connections/sections/arrival/station/id",
            "connections/sections/arrival/arrivalTimestamp"
        ]
        parameters["limit"] = 6

        ActualRoutes.routeResult = []

        Alamofire.request("https://transport.opendata.ch/v1/connections", method: .get, parameters: parameters).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                for (_, subJSON) in json["connections"] {
                    var connections: [RoutesConnections] = []
                    for (_, subJSON2) in subJSON["sections"] {
                        if subJSON2["walk"].type == .null {
                            let from = AppValues.idTransportAPIToTpgStopName[Int(subJSON2["departure"]["station"]["id"].stringValue)!] ?? (AppValues.nameTransportAPIToTpgStopName[subJSON2["departure"]["station"]["name"].stringValue] ?? subJSON2["departure"]["station"]["name"].stringValue)
                            let to = AppValues.idTransportAPIToTpgStopName[Int(subJSON2["arrival"]["station"]["id"].stringValue)!] ?? (AppValues.nameTransportAPIToTpgStopName[subJSON2["arrival"]["station"]["name"].stringValue] ?? subJSON2["arrival"]["station"]["name"].stringValue)

                            connections.append(RoutesConnections(
                                line: subJSON2["journey"]["name"].stringValue.characters.split(separator: " ").map(String.init)[1],
                                isTpg: (subJSON2["journey"]["operator"].stringValue == "TPG"),
                                isSBB: (subJSON2["journey"]["operator"].stringValue == "SBB"),
                                transportCategory: subJSON2["journey"]["categoryCode"].intValue,
                                from: from,
                                to: to,
                                direction: AppValues.nameTransportAPIToTpgStopName[subJSON2["journey"]["to"].stringValue] ?? subJSON2["journey"]["to"].stringValue,
                                departureTimestamp: subJSON2["departure"]["departureTimestamp"].intValue,
                                arrivalTimestamp: subJSON2["arrival"]["arrivalTimestamp"].intValue
                            ))
                        } else {
                            connections.append(
                                RoutesConnections(
                                    isWalk: true,
                                    from: AppValues.idTransportAPIToTpgStopName[Int(subJSON2["departure"]["station"]["id"].stringValue)!] ?? subJSON2["departure"]["station"]["name"].stringValue,
                                    to: AppValues.idTransportAPIToTpgStopName[Int(subJSON2["arrival"]["station"]["id"].stringValue)!] ?? subJSON2["arrival"]["station"]["name"].stringValue,
                                    departureTimestamp: subJSON2["departure"]["departureTimestamp"].intValue,
                                    arrivalTimestamp: subJSON2["arrival"]["arrivalTimestamp"].intValue,
                                    direction: subJSON2["walk"]["duration"].stringValue.characters.split(separator: ":").map(String.init)[1] + " minute(s)".localized
                                )
                            )
                        }
                    }
                    var dureeString = subJSON["duration"].stringValue
                    dureeString.removeSubrange(dureeString.startIndex..<dureeString.index(dureeString.startIndex, offsetBy: 3))
                    let fromRoute = AppValues.idTransportAPIToTpgStopName[Int(subJSON["from"]["station"]["id"].stringValue)!] ?? (AppValues.nameTransportAPIToTpgStopName[subJSON["from"]["station"]["name"].stringValue] ?? subJSON["to"]["station"]["name"].stringValue)
                    let toRoute = AppValues.idTransportAPIToTpgStopName[Int(subJSON["to"]["station"]["id"].stringValue)!] ?? (AppValues.nameTransportAPIToTpgStopName[subJSON["to"]["station"]["name"].stringValue] ?? subJSON["to"]["station"]["name"].stringValue)
                    ActualRoutes.routeResult.append(
                        Route(
                            from: fromRoute,
                            to: toRoute,
                            duration: dureeString,
                            departureTimestamp: subJSON["from"]["departureTimestamp"].intValue,
                            arrivalTimestamp: subJSON["to"]["arrivalTimestamp"].intValue,
                            connections: connections
                        )
                    )
                }
                if ActualRoutes.route.isArrivalDate == true {
                    ActualRoutes.routeResult = ActualRoutes.routeResult.reversed()
                }
                self.loading = false
                self.tableView.reloadData()
            } else {
                #if DEBUG
                    if let error = response.result.error {
                        let alert = SCLAlertView()
                        alert.showError("Alamofire", subTitle: "DEBUG - \(error.localizedDescription)", feedbackType: .impactMedium)
                    }
                #endif
                self.noNetwork = true
                self.loading = false
                self.tableView.allowsSelection = false
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCellTableViewCell // swiftlint:disable:this force_cast

            cell.activityIndicator.stopAnimating()

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = UIColor.flatBlue
                cell.titleLabel?.textColor = UIColor.white
                cell.subTitleLabel?.textColor = UIColor.white
                cell.activityIndicator.color = UIColor.white
            } else {
                cell.backgroundColor = UIColor.white
                cell.titleLabel?.textColor = UIColor.flatBlue
                cell.subTitleLabel?.textColor = UIColor.flatBlue
                cell.activityIndicator.color = UIColor.flatBlue
            }
            cell.titleLabel?.text = "Chargement".localized
            cell.subTitleLabel?.text = "Merci de patienter".localized
            cell.accessoryView = nil

            cell.activityIndicator.startAnimating()

            return cell
        } else if noNetwork {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listeItineaireCell", for: indexPath) as! RoutesListTableViewCell // swiftlint:disable:this force_cast
            if AppValues.primaryColor.contrast == .white {
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
                cell.backgroundColor = UIColor.flatRedDark

                cell.imageView?.image = #imageLiteral(resourceName: "internetError").maskWithColor(color: .white)
            } else {
                cell.textLabel?.textColor = UIColor.flatRedDark
                cell.detailTextLabel?.textColor = UIColor.flatRedDark
                cell.backgroundColor = UIColor.flatWhite

                cell.imageView?.image = #imageLiteral(resourceName: "internetError").maskWithColor(color: .flatRedDark)
            }

            cell.textLabel?.text = "Pas de réseau".localized

            return cell
        } else if ActualRoutes.routeResult.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listeItineaireCell", for: indexPath) as! RoutesListTableViewCell // swiftlint:disable:this force_cast
            if AppValues.primaryColor.contrast == .white {
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
                cell.backgroundColor = UIColor.flatRedDark

                cell.imageView?.image = #imageLiteral(resourceName: "internetError").maskWithColor(color: .white)
            } else {
                cell.textLabel?.textColor = UIColor.flatRedDark
                cell.detailTextLabel?.textColor = UIColor.flatRedDark
                cell.backgroundColor = UIColor.flatWhite

                cell.imageView?.image = #imageLiteral(resourceName: "internetError").maskWithColor(color: .flatRedDark)
            }

            cell.textLabel?.text = "Itinéraires non trouvés".localized

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listeItineaireCell", for: indexPath) as! RoutesListTableViewCell // swiftlint:disable:this force_cast
            cell.textLabel?.text = nil
            cell.imageView?.image = nil
            cell.departureImageView.image = #imageLiteral(resourceName: "logOut").maskWithColor(color: AppValues.textColor)

            cell.departureLabel.text = ActualRoutes.routeResult[indexPath.row].from
            cell.departureLabel.textColor = AppValues.textColor

            cell.arrivalImageView.image = #imageLiteral(resourceName: "logIn").maskWithColor(color: AppValues.textColor)

            cell.arrivalLabel.text = ActualRoutes.routeResult[indexPath.row].to
            cell.arrivalLabel.textColor = AppValues.textColor

            cell.durationImageView.image = #imageLiteral(resourceName: "clock").maskWithColor(color: AppValues.textColor)

            cell.durationLabel.text = ActualRoutes.routeResult[indexPath.row].duration
            cell.durationLabel.textColor = AppValues.textColor

            var timestamp = ActualRoutes.routeResult[indexPath.row].departureTimestamp
            cell.hourDepartureLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(timestamp!)), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
            cell.hourDepartureLabel.textColor = AppValues.textColor

            timestamp = ActualRoutes.routeResult[indexPath.row].arrivalTimestamp
            cell.hourArrivalLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(timestamp!)), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
            cell.hourArrivalLabel.textColor = AppValues.textColor

            cell.backgroundColor = AppValues.primaryColor

            let view = UIView()
            view.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = view

            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voirItineraire" {
            guard let destinationViewController = (segue.destination) as? RouteDetailTableViewController else {
                return
            }
            destinationViewController.actualRoute = ((tableView.indexPathForSelectedRow as IndexPath?)?.row)!
        }
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

        var favorite = false

        for x in AppValues.favoritesRoutes {
            if x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                favorite = true
                break
            }
        }
        if favorite {
            listeItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starNavbar"), style: UIBarButtonItemStyle.done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
        } else {
            listeItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "starEmptyNavbar"), style: UIBarButtonItemStyle.done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
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

    func scheduleNotification(_ time: Date, before: Int = 5, line: String, direction: String, arretDescente: String) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    let content = UNMutableNotificationContent()
                    if before == 0 {
                        content.title = "Départ immédiat !".localized
                        content.body = "Le tpg de la line ".localized + line + " en direction de ".localized + direction + " va partir immédiatement".localized
                    } else {
                        content.title = "Départ dans ".localized + String(before) + " minutes".localized
                        var text =  "Le tpg de la line ".localized
                        text += line
                        text += " en direction de ".localized
                        text += direction
                        text += " va partir dans ".localized
                        text += String(before)
                        text += " minutes".localized
                        content.body = text
                    }
                    content.categoryIdentifier = "departureNotifications"
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
                                SCLAlertView().showError("Impossible d'enregistrer la notification", subTitle: "L'erreur a été reportée au développeur. Merci de réessayer.", closeButtonTitle: "OK", duration: 30, feedbackType: .notificationError)
                            }
                        }
                    })
                } else {
                    SCLAlertView().showError("Notifications désactivées", subTitle: "Merci d'activer les notifications dans les réglages", closeButtonTitle: "OK", duration: 30, feedbackType: .notificationError)
                }
            }
        } else {
            let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time.addingTimeInterval(Double(before * 60) * -1))

            let cal = Calendar(identifier: Calendar.Identifier.gregorian)

            let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: time)
            let reminder = UILocalNotification()
            reminder.fireDate = date

            var texte =  "Le tpg de la line ".localized
            texte += line
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
        let time = Date(timeIntervalSince1970: Double(ActualRoutes.routeResult[indexPath.row].departureTimestamp)).timeIntervalSince(Date())
        let timerAction = UITableViewRowAction(style: .default, title: "Rappeler".localized) { (action, indexPath) in
            let alertView = SCLAlertView()
            if time < 60 {
                alertView.showWarning("Le bus arrive".localized, subTitle: "Dépêchez vous, vous allez le rater !".localized, closeButtonTitle: "OK".localized, duration: 10, feedbackType: .notificationWarning)
            } else {
                alertView.addButton("A l'heure du départ".localized, action: { () -> Void in
                    self.scheduleNotification(Date(timeIntervalSinceNow: time), before: 0, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)

                })
                if time > 60 * 5 {
                    alertView.addButton("5 min avant le départ".localized, action: { () -> Void in
                        self.scheduleNotification(Date(timeIntervalSinceNow: time), before: 5, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
                    })
                }
                if time > 60 * 10 {
                    alertView.addButton("10 min avant le départ".localized, action: { () -> Void in
                        self.scheduleNotification(Date(timeIntervalSinceNow: time), before: 10, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
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
                            SCLAlertView().showError("Il y a un problème".localized, subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized, closeButtonTitle: "OK", duration: 10, feedbackType: .notificationError)

                        } else {
                            self.scheduleNotification(Date(timeIntervalSinceNow: time), before: Int(txt.text!)!, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: #imageLiteral(resourceName: "clock").maskWithColor(color: .white))
                })
                alertView.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: #imageLiteral(resourceName: "clock").maskWithColor(color: .white))
                tableView.setEditing(false, animated: true)
            }

        }
        timerAction.backgroundColor = UIColor.flatBlue
        return [timerAction]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if noNetwork || ActualRoutes.routeResult.count == 0 {
            return false
        } else {
            return true
        }
    }
}

extension RoutesListTableViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "routeDetailTableViewController") as? RouteDetailTableViewController else { return nil }

        detailVC.actualRoute = indexPath.row

        previewingContext.sourceRect = cell.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
