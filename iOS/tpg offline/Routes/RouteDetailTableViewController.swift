//
//  RouteDetailTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Chameleon
import FontAwesomeKit
import UserNotifications

class RouteDetailTableViewController: UITableViewController {

    var actualRoute = 0
    let defaults = UserDefaults.standard
    var favorite = false

    override func viewDidLoad() {
        super.viewDidLoad()

        var itemsList: [UIBarButtonItem] = []

        for x in AppValues.favoritesRoutes {
            if x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                favorite = true
                break
            }
        }
        if favorite {
            itemsList.append(UIBarButtonItem(image: FAKFontAwesome.starIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RouteDetailTableViewController.toggleFavorite(_:))))
        } else {
            itemsList.append(UIBarButtonItem(image: FAKFontAwesome.starOIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RouteDetailTableViewController.toggleFavorite(_:))))
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

        var couleurTexte = UIColor.white

        if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].transportCategory != .walk {

            if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].isSBB {
                cell.lineLabel.text = "Train ".localized + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
            } else {
                cell.lineLabel.text = "Ligne ".localized + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
            }

            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)

                if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].isTpg {
                    cell.backgroundColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]
                    couleurTexte = AppValues.linesColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!

                    let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                    labelPictoLigne.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
                    labelPictoLigne.textAlignment = .center
                    labelPictoLigne.textColor = couleurTexte
                    labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                    labelPictoLigne.layer.borderColor = couleurTexte.cgColor
                    labelPictoLigne.layer.borderWidth = 1
                    let image = labelToImage(labelPictoLigne)
                    for x in cell.iconImageView.constraints {
                        if x.identifier == "iconeImageViewHeight" {
                            x.constant = 24
                        }
                    }
                    cell.iconImageView.image = image
                } else {
                    cell.iconImageView.image = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].getImageofType(42, color: UIColor.white)
                    for x in cell.iconImageView.constraints {
                        if x.identifier == "iconeImageViewHeight" {
                            x.constant = 42
                        }
                    }
                }
                let attributedString = NSMutableAttributedString(attributedString: ActualRoutes.routeResult[actualRoute].connections[indexPath.row].getAttributedStringofType(24, color: UIColor.white))
                attributedString.append(NSAttributedString(string: " " + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].direction))
                cell.directionLabel.attributedText = attributedString
            } else {
                couleurTexte = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                cell.backgroundColor = UIColor.white

                if ActualRoutes.routeResult[actualRoute].connections[indexPath.row].isTpg {

                    cell.backgroundColor = UIColor.white

                    let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                    labelPictoLigne.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line
                    labelPictoLigne.textAlignment = .center
                    labelPictoLigne.textColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!
                    labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                    labelPictoLigne.layer.borderColor = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!.cgColor
                    labelPictoLigne.layer.borderWidth = 1

                    couleurTexte = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!

                    if ContrastColorOf(AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!, returnFlat: true) == FlatWhite() {
                        couleurTexte = AppValues.linesBackgroundColor[ActualRoutes.routeResult[actualRoute].connections[indexPath.row].line]!
                    } else {
                        couleurTexte = couleurTexte.darken(byPercentage: 0.2)!
                        labelPictoLigne.textColor = labelPictoLigne.textColor.darken(byPercentage: 0.2)
                        labelPictoLigne.layer.borderColor = UIColor(cgColor: labelPictoLigne.layer.borderColor!).darken(byPercentage: 0.2)?.cgColor
                    }

                    let image = labelToImage(labelPictoLigne)
                    cell.iconImageView.image = image
                    for x in cell.iconImageView.constraints {
                        if x.identifier == "iconeImageViewHeight" {
                            x.constant = 24
                        }
                    }
                } else {
                    cell.iconImageView.image = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].getImageofType(42, color: couleurTexte)
                }
                let attributedString = NSMutableAttributedString(attributedString: ActualRoutes.routeResult[actualRoute].connections[indexPath.row].getAttributedStringofType(24, color: couleurTexte))
                attributedString.append(NSAttributedString(string: " " + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].direction))
                cell.directionLabel.attributedText = attributedString
            }
        } else {
            let icone = FAKIonIcons.androidWalkIcon(withSize: 42)!

            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.backgroundColor = UIColor.white
            couleurTexte = AppValues.textColor

            cell.departureLabel.text = ""
            cell.hourDepartureLabel.text = ""
            cell.arrivalLabel.text = ""
            cell.hourArrivalLabel.text = ""

            cell.iconImageView.image = icone.image(with: CGSize(width: 42, height: 42))
            cell.lineLabel.text = "Marche".localized
            cell.directionLabel.text = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].direction

        }

        cell.lineLabel.textColor = couleurTexte
        cell.directionLabel.textColor = couleurTexte
        cell.departureLabel.textColor = couleurTexte
        cell.hourDepartureLabel.textColor = couleurTexte
        cell.arrivalLabel.textColor = couleurTexte
        cell.hourArrivalLabel.textColor = couleurTexte

        var icone2 = FAKIonIcons.logOutIcon(withSize: 21)!
        icone2.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        var attributedString = NSMutableAttributedString(attributedString: (icone2.attributedString())!)
        attributedString.append(NSAttributedString(string: " " + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].from))
        cell.departureLabel.attributedText = attributedString

        var timestamp = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].departureTimestamp
        cell.hourDepartureLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(timestamp)), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)

        timestamp = ActualRoutes.routeResult[actualRoute].connections[indexPath.row].arrivalTimestamp
        cell.hourArrivalLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(timestamp)), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)

        icone2 = FAKIonIcons.logInIcon(withSize: 21)!
        icone2.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        attributedString = NSMutableAttributedString(attributedString: (icone2.attributedString())!)
        attributedString.append(NSAttributedString(string: " " + ActualRoutes.routeResult[actualRoute].connections[indexPath.row].to))
        cell.arrivalLabel.attributedText = attributedString

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
        for x in AppValues.favoritesRoutes {
            if x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                favoris = true
                break
            }
        }
        if favoris {
            listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action:#selector(RouteDetailTableViewController.toggleFavorite(_:))))
        } else {
            listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RouteDetailTableViewController.toggleFavorite(_:))))
        }
        self.navigationItem.rightBarButtonItems = listeItems
        guard let navController = self.splitViewController?.viewControllers[0] as? UINavigationController else {
            return
        }
        guard let routesViewController = navController.viewControllers[0] as? RoutesTableViewController else {
            return
        }
        routesViewController.tableView.reloadData()
    }

    func scheduleNotification(_ time: Date, before: Int = 5, ligne: String, direction: String, arretDescente: String) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    let content = UNMutableNotificationContent()
                    if before == 0 {
                        content.title = "Départ immédiat !".localized
                        content.body = "Le tpg de la line ".localized + ligne + " en direction de ".localized + direction + " va partir immédiatement. ".localized + "Descendez à ".localized + String(arretDescente)
                    } else {
                        content.title = "Départ dans ".localized + String(before) + " minutes".localized
                        var text =  "Le tpg de la line ".localized
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
                    content.userInfo = [:]
                    content.sound = UNNotificationSound.default()

                    let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time.addingTimeInterval(Double(before * 60) * -1))
                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: time)

                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!), repeats: false)

                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in
                        if error == nil {
                            let okView = SCLAlertView()
                            if before == 0 {
                                okView.showSuccess("Vous serez notifié".localized, subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized, closeButtonTitle: "OK", duration: 10)
                            } else {
                                var texte =  "La notification à été enregistrée et sera affichée ".localized
                                texte += String(before)
                                texte += " minutes avant le départ.".localized
                                okView.showSuccess("Vous serez notifié".localized, subTitle: texte, closeButtonTitle: "OK", duration: 10)
                            }
                        } else {
                            SCLAlertView().showError("Impossible d'enregistrer la notification", subTitle: "L'erreur a été reportée au développeur. Merci de réessayer.", closeButtonTitle: "OK", duration: 30)
                        }
                    })
                } else {
                    SCLAlertView().showError("Notifications désactivées", subTitle: "Merci d'activer les notifications dans les réglages", closeButtonTitle: "OK", duration: 30)
                }
            }
        } else {
            let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time.addingTimeInterval(Double(before * 60) * -1))

            let cal = Calendar(identifier: Calendar.Identifier.gregorian)

            let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: time)
            let reminder = UILocalNotification()
            reminder.fireDate = date

            var texte =  "Le tpg de la line ".localized
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

            print("Firing at \(now.hour):\(now.minute! - before):\(now.second)")

            let okView = SCLAlertView()
            if before == 0 {
                okView.showSuccess("Vous serez notifié".localized, subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized, closeButtonTitle: "OK".localized, duration: 10)
            } else {
                var texte = "La notification à été enregistrée et sera affichée ".localized
                texte += String(before)
                texte += " minutes avant le départ.".localized
                okView.showSuccess("Vous serez notifié".localized, subTitle: texte, closeButtonTitle: "OK".localized, duration: 10)
            }
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let time = Date(timeIntervalSince1970: Double(ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].departureTimestamp)).timeIntervalSince(Date())
        let timerAction = UITableViewRowAction(style: .default, title: "Rappeler".localized) { (action, indexPath) in
            let icone = FAKIonIcons.iosClockIcon(withSize: 20)!
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
            icone.image(with: CGSize(width: 20, height: 20))
            let alertView = SCLAlertView()
            if time < 60 {
                alertView.showWarning("Le bus arrive".localized, subTitle: "Dépêchez vous, vous allez le rater !".localized, closeButtonTitle: "OK".localized, duration: 10)
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
                            SCLAlertView().showError("Il y a un problème".localized, subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized, closeButtonTitle: "OK", duration: 10)

                        } else {
                            self.scheduleNotification(Date(timeIntervalSinceNow: time), before: Int(txt.text!)!, ligne: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].line, direction: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].direction, arretDescente: ActualRoutes.routeResult[self.actualRoute].connections[indexPath.row].to)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: icone.image(with: CGSize(width: 20, height: 20)))
                })
                alertView.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: icone.image(with: CGSize(width: 20, height: 20)))
                tableView.setEditing(false, animated: true)
            }

        }
        timerAction.backgroundColor = UIColor.flatBlue
        return [timerAction]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
