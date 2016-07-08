//
//  RoutesListTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView
import MRProgress
import SwiftDate
import Alamofire

class RoutesListTableViewController: UITableViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var favorite = false
    var noNetwork = false
    var loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ActualRoutes.routeResult = []
        tableView.backgroundColor = AppValues.primaryColor
        
        if ActualRoutes.route.departure != nil && ActualRoutes.route.arrival != nil && ActualRoutes.route.date != nil {
            loading = true
            refresh()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
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
                    listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
                }
                else {
                    listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
                }
            self.navigationItem.rightBarButtonItems = listeItems
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true {
            return 1
        }
        else if ActualRoutes.route == nil {
            return 0
        }
        else if ActualRoutes.route.departure == nil || ActualRoutes.route.arrival == nil || ActualRoutes.route.date == nil {
            return 0
        }
        else if noNetwork {
            return 1
        }
        else if ActualRoutes.routeResult.count == 0 {
            return 1
        }
        else {
            return ActualRoutes.routeResult.count
        }
    }
    
    func refresh() {
        self.loading = true
        self.tableView.reloadData()
        let parameters: [String:AnyObject] = [
            "key": "d95be980-0830-11e5-a039-0002a5d5c51b",
            "from": ActualRoutes.route.departure!.transportAPIiD,
            "to": ActualRoutes.route.arrival!.transportAPIiD,
            "date": String(ActualRoutes.route.date!.year) + "-" + String(ActualRoutes.route.date!.month) + "-" + String(ActualRoutes.route.date!.day),
            "time": String(ActualRoutes.route.date!.hour) + ":" + String(ActualRoutes.route.date!.minute),
            "isArrivalTime": String(Int(ActualRoutes.route.isArrivalDate)),
            "fields": [
                "connections/duration",
                "connections/from/station/name",
                "connections/from/departureTimestamp",
                "connections/to/station/name",
                "connections/to/arrivalTimestamp",
                "connections/sections/walk",
                "connections/sections/journey/name",
                "connections/sections/journey/operator",
                "connections/sections/journey/categoryCode",
                "connections/sections/journey/walk/duration",
                "connections/sections/journey/to",
                "connections/sections/departure/station/name",
                "connections/sections/departure/departureTimestamp",
                "connections/sections/arrival/station/name",
                "connections/sections/arrival/arrivalTimestamp"
            ],
            "limit": 6
        ]
        
        ActualRoutes.routeResult = []
        Alamofire.request(.GET, "http://transport.opendata.ch/v1/connections", parameters: parameters).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                for (_, subJSON) in json["connections"] {
                    var connections: [RoutesConnections] = []
                    for (_, subJSON2) in subJSON["sections"] {
                        if subJSON2["walk"].type == .Null {
                            connections.append(RoutesConnections(
                                line: subJSON2["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1],
                                isTpg: (subJSON2["journey"]["operator"].stringValue == "TPG"),
                                isSBB: (subJSON2["journey"]["operator"].stringValue == "SBB"),
                                transportCategory: subJSON2["journey"]["categoryCode"].intValue,
                                from: subJSON2["departure"]["station"]["name"].stringValue,
                                to: subJSON2["arrival"]["station"]["name"].stringValue,
                                direction: subJSON2["journey"]["to"].stringValue,
                                departureTimestamp: subJSON2["departure"]["departureTimestamp"].intValue,
                                arrivalTimestamp: subJSON2["arrival"]["arrivalTimestamp"].intValue
                                ))
                        }
                        else {
                            connections.append(
                            RoutesConnections(
                                    isWalk: true,
                                    from: subJSON2["departure"]["station"]["name"].stringValue,
                                    to: subJSON2["arrival"]["station"]["name"].stringValue,
                                    departureTimestamp: subJSON2["departure"]["departureTimestamp"].intValue,
                                    arrivalTimestamp: subJSON2["arrival"]["arrivalTimestamp"].intValue,
                                    direction: subJSON2["walk"]["duration"].stringValue.characters.split(":").map(String.init)[1] + " minute(s)".localized()
                                )
                            )
                        }
                    }
                    var dureeString = subJSON["duration"].stringValue
                    dureeString.removeRange(dureeString.startIndex..<dureeString.startIndex.advancedBy(3))
                    ActualRoutes.routeResult.append(
                        Route(
                            from: subJSON["from"]["station"]["name"].stringValue,
                            to: subJSON["to"]["station"]["name"].stringValue,
                            duration: dureeString,
                            departureTimestamp: subJSON["from"]["departureTimestamp"].intValue,
                            arrivalTimestamp: subJSON["to"]["arrivalTimestamp"].intValue,
                            connections: connections
                        )
                    )
                }
                if ActualRoutes.route.isArrivalDate == true {
                    ActualRoutes.routeResult = ActualRoutes.routeResult.reverse()
                }
                self.loading = false
                self.tableView.reloadData()
            }
            else {
                AppValues.logger.error(response.result.error)
                self.noNetwork = true
                self.loading = false
                self.tableView.allowsSelection = false
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if loading == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell", forIndexPath: indexPath) as! loadingCellTableViewCell
            
            cell.activityIndicator.stopAnimation()
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor.flatBlueColor()
                cell.titleLabel?.textColor = UIColor.whiteColor()
                cell.subTitleLabel?.textColor = UIColor.whiteColor()
                cell.activityIndicator.color = UIColor.whiteColor()
            }
            else {
                cell.backgroundColor = UIColor.whiteColor()
                cell.titleLabel?.textColor = UIColor.flatBlueColor()
                cell.subTitleLabel?.textColor = UIColor.flatBlueColor()
                cell.activityIndicator.color = UIColor.flatBlueColor()
            }
            cell.titleLabel?.text = "Chargement".localized()
            cell.subTitleLabel?.text = "Merci de patienter".localized()
            cell.accessoryView = nil
            
            cell.activityIndicator.startAnimation()
            
            return cell
        }
            
        else if noNetwork {
            let cell = tableView.dequeueReusableCellWithIdentifier("listeItineaireCell", forIndexPath: indexPath) as! RoutesListTableViewCell
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.detailTextLabel?.textColor = UIColor.whiteColor()
                cell.backgroundColor = UIColor.flatRedColorDark()
                
                let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            }
            else {
                cell.textLabel?.textColor = UIColor.flatRedColorDark()
                cell.detailTextLabel?.textColor = UIColor.flatRedColorDark()
                cell.backgroundColor = UIColor.flatWhiteColor()
                
                let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatRedColorDark())
                cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            }
            
            cell.textLabel?.text = "Pas de réseau".localized()
            
            return cell
        }
            
        else if ActualRoutes.routeResult.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("listeItineaireCell", forIndexPath: indexPath) as! RoutesListTableViewCell
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.detailTextLabel?.textColor = UIColor.whiteColor()
                cell.backgroundColor = UIColor.flatRedColorDark()
                
                let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            }
            else {
                cell.textLabel?.textColor = UIColor.flatRedColorDark()
                cell.detailTextLabel?.textColor = UIColor.flatRedColorDark()
                cell.backgroundColor = UIColor.flatWhiteColor()
                
                let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatRedColorDark())
                cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            }
            
            cell.textLabel?.text = "Itinéraires non trouvés".localized()
            
            return cell
        }
            
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("listeItineaireCell", forIndexPath: indexPath) as! RoutesListTableViewCell
            cell.textLabel?.text = nil
            cell.imageView?.image = nil
            var icone = FAKIonIcons.logOutIconWithSize(21)
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
            attributedString.appendAttributedString(NSAttributedString(string: " " + ActualRoutes.routeResult[indexPath.row].from))
            cell.departureLabel.attributedText = attributedString
            cell.departureLabel.textColor = AppValues.textColor
            
            icone = FAKIonIcons.logInIconWithSize(21)
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
            attributedString.appendAttributedString(NSAttributedString(string: " " + ActualRoutes.routeResult[indexPath.row].to))
            cell.arrivalLabel.attributedText = attributedString
            cell.arrivalLabel.textColor = AppValues.textColor
            
            icone = FAKIonIcons.clockIconWithSize(21)
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
            attributedString.appendAttributedString(NSAttributedString(string: " " + ActualRoutes.routeResult[indexPath.row].duration))
            cell.durationLabel.attributedText = attributedString
            cell.durationLabel.textColor = AppValues.textColor
            
            var timestamp = ActualRoutes.routeResult[indexPath.row].departureTimestamp
            cell.hourDepartureLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            cell.hourDepartureLabel.textColor = AppValues.textColor
            
            timestamp = ActualRoutes.routeResult[indexPath.row].arrivalTimestamp
            cell.hourArrivalLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            cell.hourArrivalLabel.textColor = AppValues.textColor
            
            cell.backgroundColor = AppValues.primaryColor
            
            let view = UIView()
            view.backgroundColor = AppValues.primaryColor
            cell.selectedBackgroundView = view
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "voirItineraire" {
            let destinationViewController: RouteDetailTableViewController = (segue.destinationViewController) as! RouteDetailTableViewController
            destinationViewController.actualRoute = (tableView.indexPathForSelectedRow?.row)!
        }
    }
    func toggleFavorite(sender: AnyObject!) {
        if AppValues.favoritesRoutes.isEmpty {
            AppValues.favoritesRoutes = [[ActualRoutes.route.departure!, ActualRoutes.route.arrival!]]
        }
        else {
            if self.favorite {
                AppValues.favoritesRoutes = AppValues.favoritesRoutes.filter({ (arretA) -> Bool in
                    if arretA[0].fullName == ActualRoutes.route.departure?.fullName && arretA[1].fullName == ActualRoutes.route.arrival?.fullName {
                        return false
                    }
                    return true
                })
            }
            else {
                AppValues.favoritesRoutes.append([ActualRoutes.route.departure!, ActualRoutes.route.arrival!])
            }
        }
        
        self.favorite = !self.favorite
        
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.favoritesRoutes)
        defaults.setObject(encodedData, forKey: "itinerairesFavoris")
        
        var listeItems: [UIBarButtonItem] = []
        
        var favoris = false
        
        for x in AppValues.favoritesRoutes {
            if x[0].fullName == ActualRoutes.route.departure?.fullName && x[1].fullName == ActualRoutes.route.arrival?.fullName {
                favoris = true
                break
            }
        }
        if favoris {
            listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
        }
        else {
            listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RoutesListTableViewController.toggleFavorite(_:))))
        }
        self.navigationItem.rightBarButtonItems = listeItems
        let navController = self.splitViewController?.viewControllers[0] as! UINavigationController
        if (navController.viewControllers[0].isKindOfClass(RoutesTableViewController)) {
            let itineraireTableViewController = navController.viewControllers[0] as! RoutesTableViewController
            itineraireTableViewController.tableView.reloadData()
        }
    }
    func scheduleNotification(time: NSDate, before: Int = 5, line: String, direction: String, arretDescente: String) {
        let time2 = time - before.minutes
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time2)
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let date = cal.dateBySettingHour(now.hour, minute: now.minute, second: now.second, ofDate: time, options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate = date
        
        var texte =  "Le tpg de la line ".localized()
        texte += line
        texte += " en direction de ".localized()
        texte += direction
        if before == 0 {
            texte += " va partir immédiatement. ".localized()
        }
        else {
            texte += " va partir dans ".localized()
            texte += String(before)
            texte += " minutes. ".localized()
        }
        texte += "Descendez à ".localized()
        texte += String(arretDescente)
        
        reminder.alertBody = texte
        reminder.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        AppValues.logger.info("Firing at \(now.hour):\(now.minute - before):\(now.second)")
        
        let okView = SCLAlertView()
        if before == 0 {
            okView.showSuccess("Vous serez notifié".localized(), subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized(), closeButtonTitle: "OK".localized(), duration: 10)
        }
        else {
            var texte = "La notification à été enregistrée et sera affichée ".localized()
            texte += String(before)
            texte += " minutes avant le départ.".localized()
            okView.showSuccess("Vous serez notifié".localized(), subTitle: texte, closeButtonTitle: "OK".localized(), duration: 10)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let time = NSDate(timeIntervalSince1970: Double(ActualRoutes.routeResult[indexPath.row].departureTimestamp)).timeIntervalSinceDate(NSDate())
        let timerAction = UITableViewRowAction(style: .Default, title: "Rappeler".localized()) { (action, indexPath) in
            let icone = FAKIonIcons.iosClockIconWithSize(20)
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            icone.imageWithSize(CGSize(width: 20, height: 20))
            let alertView = SCLAlertView()
            if time < 60 {
                alertView.showWarning("Le bus arrive".localized(), subTitle: "Dépêchez vous, vous allez le rater !".localized(), closeButtonTitle: "OK".localized(), duration: 10)
            }
            else {
                alertView.addButton("A l'heure du départ".localized(), action: { () -> Void in
                    self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 0, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
                    
                })
                if time > 60 * 5 {
                    alertView.addButton("5 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 5, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
                    })
                }
                if time > 60 * 10 {
                    alertView.addButton("10 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 10, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
                    })
                }
                alertView.addButton("Autre", action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombre de minutes".localized())
                    txt.keyboardType = .NumberPad
                    txt.becomeFirstResponder()
                    customValueAlert.addButton("Rappeler".localized(), action: { () -> Void in
                        if Int(time) < Int(txt.text!)! * 60 {
                            customValueAlert.hideView()
                            SCLAlertView().showError("Il y a un problème".localized(), subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized(), closeButtonTitle: "OK", duration: 10)
                            
                        }
                        else {
                            self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: Int(txt.text!)!, line: ActualRoutes.routeResult[indexPath.row].connections[0].line, direction: ActualRoutes.routeResult[indexPath.row].connections[0].direction, arretDescente:  ActualRoutes.routeResult[indexPath.row].connections[0].to)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler".localized(), subTitle: "Quand voulez-vous être notifié(e) ?".localized(), closeButtonTitle: "Annuler".localized(), circleIconImage: icone.imageWithSize(CGSize(width: 20, height: 20)))
                })
                alertView.showNotice("Rappeler".localized(), subTitle: "Quand voulez-vous être notifié(e) ?".localized(), closeButtonTitle: "Annuler".localized(), circleIconImage: icone.imageWithSize(CGSize(width: 20, height: 20)))
                tableView.setEditing(false, animated: true)
            }
            
        }
        timerAction.backgroundColor = UIColor.flatBlueColor()
        return [timerAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if noNetwork || ActualRoutes.routeResult.count == 0 {
            return false
        }
        else {
            return true
        }
    }
}
