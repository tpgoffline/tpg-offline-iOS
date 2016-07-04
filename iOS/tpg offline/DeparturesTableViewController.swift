//
//  DeparturesTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit
import SCLAlertView
import ChameleonFramework
import DGElasticPullToRefresh
import MRProgress
import SwiftDate
import Alamofire
import NVActivityIndicatorView
import WatchConnectivity

class DeparturesTableViewController: UITableViewController {
    var stop: Stop? = nil
    var departuresList: [Departures]! = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var offline = false
    var noMoreTransport = false
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if stop == nil {
            stop = AppValues.stops[[String](AppValues.stops.keys).sort()[0]]
        }
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refresh()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darkenByPercentage(0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        title = stop?.fullName
        
        tableView.backgroundColor = AppValues.primaryColor
        
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darkenByPercentage(0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        refreshTheme()
        
        if stop != nil {
            var barButtonsItems: [UIBarButtonItem] = []
            
            if ((AppValues.fullNameFavoritesStops.indexOf(stop!.fullName)) != nil) {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.toggleFavorite(_:))))
            }
            else {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action:#selector(DeparturesTableViewController.toggleFavorite(_:))))
            }
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.showItinerary(_:))))
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.refresh)))
            
            self.navigationItem.rightBarButtonItems = barButtonsItems
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        tableView?.dg_removePullToRefresh()
    }
    
    func labelToImage(label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func toggleFavorite(sender: AnyObject!) {
        if AppValues.favoritesStops.isEmpty {
            let array: [String:Stop] = [stop!.fullName: stop!]
            AppValues.fullNameFavoritesStops.append(stop!.fullName)
            AppValues.favoritesStops = array
            
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(array)
            defaults.setObject(encodedData, forKey: "favoritesStops")
        }
        else {
            if ((AppValues.fullNameFavoritesStops.indexOf(stop!.fullName)) != nil) {
                AppValues.favoritesStops.removeValueForKey(stop!.fullName)
                AppValues.fullNameFavoritesStops.removeAtIndex(AppValues.fullNameFavoritesStops.indexOf(stop!.fullName)!)
            }
            else {
                AppValues.favoritesStops![stop!.fullName] = stop
                AppValues.fullNameFavoritesStops.append(stop!.fullName)
            }
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.favoritesStops!)
            defaults.setObject(encodedData, forKey: "favoritesStops")
        }
        
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                do {
                    var a: [String:[String:AnyObject]] = [:]
                    for (x, y) in AppValues.favoritesStops {
                        a[x] = y.toDictionnary()
                    }
                    var offlineDepartures: [String:String] = [:]
                    if (AppValues.premium == true) {
                        var path = ""
                        for (_, y) in AppValues.favoritesStops {
                            var json = JSON(data: "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
                            var departuresArray: [String:String] = [:]
                            if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                                path = dir.stringByAppendingPathComponent(y.stopCode + "departsSAM.json")
                                
                                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                                    do {
                                        try departuresArray["SAM"] = String(contentsOfFile: path)
                                    } catch {
                                        print("Reading of \(path) is failed")
                                    }
                                }
                                
                                path = dir.stringByAppendingPathComponent(y.stopCode + "departsDIM.json")
                                
                                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                                    do {
                                        try departuresArray["DIM"] = String(contentsOfFile: path)
                                    } catch {
                                        print("Reading of \(path) is failed")
                                    }
                                }
                                
                                path = dir.stringByAppendingPathComponent(y.stopCode + "departsLUN.json")
                                
                                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                                    do {
                                        try departuresArray["LUN"] = String(contentsOfFile: path)
                                    } catch {
                                        print("Reading of \(path) is failed")
                                    }
                                }
                            }
                            json.dictionaryObject = departuresArray
                            offlineDepartures[y.stopCode] = json.rawString() ?? ""
                        }
                        
                    }
                    try WatchSessionManager.sharedManager.updateApplicationContext(["favoritesStops": NSKeyedArchiver.archivedDataWithRootObject(a), "offlineDepartures": offlineDepartures])
                    
                } catch {
                    AppValues.logger.error("Update WatchConnectivity with application context failed")
                }
            }
        }
        
        var barButtonsItems: [UIBarButtonItem] = []
        
        if ((AppValues.fullNameFavoritesStops.indexOf(stop!.fullName)) != nil) {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.toggleFavorite(_:))))
        }
        else {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.toggleFavorite(_:))))
        }
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.showItinerary(_:))))
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DeparturesTableViewController.refresh)))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems
        let navController = self.splitViewController?.viewControllers[0] as! UINavigationController
        if (navController.viewControllers[0].isKindOfClass(StopsTableViewController)) {
            let arretTableViewController = navController.viewControllers[0] as! StopsTableViewController
            arretTableViewController.tableView.reloadData()
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "showLigne" && departuresList[tableView.indexPathForSelectedRow!.row].leftTime == "no more") {
            return false
        }
        else {
            return true
        }
    }
    
    func showItinerary(sender: AnyObject!) {
        performSegueWithIdentifier("showItinerary", sender: self)
    }
    
    func scheduleNotification(hour: String, before: Int, line: String, direction: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        var time = dateFormatter.dateFromString(hour)
        time = time! - before.minutes
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time!)
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date = cal.dateBySettingHour(now.hour, minute: now.minute, second: now.second, ofDate: NSDate(), options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate = date
        reminder.soundName = UILocalNotificationDefaultSoundName
        if before == 0 {
            reminder.alertBody = "Le tpg de la line ".localized() + line + " en direction de ".localized() + direction + " va partir immédiatement".localized()
        }
        else {
            var texte =  "Le tpg de la line ".localized()
            texte += line
            texte += " en direction de ".localized()
            texte += direction
            texte += " va partir dans ".localized()
            texte += String(before)
            texte += " minutes".localized()
            reminder.alertBody = texte
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        AppValues.logger.debug("Firing at \(now.hour):\(now.minute-before):\(now.second)")
        
        let okView = SCLAlertView()
        if before == 0 {
            okView.showSuccess("Vous serez notifié".localized(), subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized(), closeButtonTitle: "OK", duration: 10)
        }
        else {
            var texte =  "La notification à été enregistrée et sera affichée ".localized()
            texte += String(before)
            texte += " minutes avant le départ.".localized()
            okView.showSuccess("Vous serez notifié".localized(), subTitle: texte, closeButtonTitle: "OK", duration: 10)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showItinerary" {
            let routeViewController: RouteToStopViewController = (segue.destinationViewController) as! RouteToStopViewController
            routeViewController.stop = self.stop
        }
        else if segue.identifier == "showLigne" {
            let voirLigneTableViewController: ThermometerTableViewController = (segue.destinationViewController) as! ThermometerTableViewController
            voirLigneTableViewController.departure = departuresList[(tableView.indexPathForSelectedRow?.row)!]
        }
        else if segue.identifier == "showAllDepartures" {
            let indexPath = sender as! NSIndexPath
            let voirTousLesDepartsViewController: SeeAllDeparturesViewController = (segue.destinationViewController) as! SeeAllDeparturesViewController
            voirTousLesDepartsViewController.stop = self.stop!
            voirTousLesDepartsViewController.line = self.departuresList[indexPath.row].line
            voirTousLesDepartsViewController.direction = self.departuresList[indexPath.row].direction
            voirTousLesDepartsViewController.destinationCode = self.departuresList[indexPath.row].destinationCode
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func refresh() {
        self.loading = true
        self.tableView.reloadData()
        departuresList = []
        Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": stop!.stopCode])
            .responseJSON { response in
                if let data = response.result.value {
                    let departs = JSON(data)
                    for (_, subjson) in departs["departures"] {
                        if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                            self.departuresList.append(Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: UIColor.whiteColor(),
                                lineBackgroundColor: UIColor.flatGrayColor(),
                                
                                code: String(subjson["departureCode"].intValue ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                                ))
                        }
                        else {
                            self.departuresList.append(Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: AppValues.linesColor[subjson["line"]["lineCode"].string!]!,
                                lineBackgroundColor: AppValues.linesBackgroundColor[subjson["line"]["lineCode"].string!]!,
                                
                                code: String(subjson["departureCode"].intValue ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                                ))
                        }
                    }
                    self.offline = false
                    self.tableView.allowsSelection = true
                    
                    if self.departuresList.count == 0 {
                        self.noMoreTransport = true
                    }
                    else {
                        self.noMoreTransport = false
                    }
                    self.loading = false
                    self.tableView.reloadData()
                    self.tableView.dg_stopLoading()
                }
                else {
                    if AppValues.premium == true {
                        let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
                        var path = ""
                        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                            switch day.weekday {
                            case 7:
                                
                                path = dir.stringByAppendingPathComponent(self.stop!.stopCode + "departsSAM.json")
                                break
                            case 1:
                                path = dir.stringByAppendingPathComponent(self.stop!.stopCode + "departsDIM.json");
                                break
                            default:
                                path = dir.stringByAppendingPathComponent(self.stop!.stopCode + "departsLUN.json");
                                
                                break
                            }
                        }
                        
                        if NSFileManager.defaultManager().fileExistsAtPath(path) {
                            let dataDeparts = NSData(contentsOfFile: path)
                            let departs = JSON(data: dataDeparts!)
                            for (_, subJson) in departs {
                                if AppValues.linesColor[subJson["ligne"].string!] != nil {
                                    self.departuresList.append(Departures(
                                        line: subJson["ligne"].string!,
                                        direction: subJson["destination"].string!,
                                        destinationCode: "",
                                        lineColor: AppValues.linesColor[subJson["ligne"].string!]!,
                                        lineBackgroundColor: AppValues.linesBackgroundColor[subJson["ligne"].string!]!,
                                        code: nil,
                                        leftTime: "0",
                                        timestamp: subJson["timestamp"].string!
                                        ))
                                }
                                else {
                                    self.departuresList.append(Departures(
                                        line: subJson["ligne"].string!,
                                        direction: subJson["destination"].string!,
                                        destinationCode: "",
                                        lineColor: UIColor.whiteColor(),
                                        lineBackgroundColor: UIColor.flatGrayColorDark(),
                                        code: nil,
                                        leftTime: "0",
                                        timestamp: subJson["timestamp"].string!
                                        ))
                                }
                                self.departuresList.last?.calculerTempsRestant()
                            }
                        }
                        
                        self.departuresList = self.departuresList.filter({ (depart) -> Bool in
                            if depart.leftTime != "-1" {
                                return true
                            }
                            return false
                        })
                        
                        self.departuresList.sortInPlace({ (depart1, depart2) -> Bool in
                            if Int(depart1.leftTime) < Int(depart2.leftTime) {
                                return true
                            }
                            return false
                        })
                        
                        self.offline = true
                        
                        if self.departuresList.count == 0 {
                            self.noMoreTransport = true
                        }
                        else {
                            self.noMoreTransport = false
                        }
                        self.loading = false
                        
                        self.tableView.allowsSelection = false
                        self.tableView.reloadData()
                        self.tableView.dg_stopLoading()
                    }
                    else {
                        self.offline = true
                        self.tableView.allowsSelection = false
                        self.departuresList = []
                        self.noMoreTransport = false
                        self.loading = false
                        self.tableView.reloadData()
                        self.tableView.dg_stopLoading()
                    }
                }
        }
    }
}

extension DeparturesTableViewController {
    // MARK: tableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loading == true {
            return 1
        }
        else if offline {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true {
            return 1
        }
        else if offline && section == 0 {
            return 1
        }
        else if offline && section == 1 && noMoreTransport {
            return 1
        }
        else if !offline && section == 0 && noMoreTransport {
            return 1
        }
        else {
            return departuresList.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if loading == true {
            return 60
        }
        else if offline && indexPath.section == 0 {
            return 60
        }
        else if offline && indexPath.section == 1 && noMoreTransport {
            return 60
        }
        else if !offline && indexPath.section == 0 && noMoreTransport {
            return 60
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let timerAction = UITableViewRowAction(style: .Default, title: "Rappeler".localized()) { (action, indexPath) in
            let icone = FAKIonIcons.iosClockIconWithSize(20)
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            icone.imageWithSize(CGSize(width: 20, height: 20))
            let alertView = SCLAlertView()
            if self.departuresList[indexPath.row].leftTime == "0" {
                alertView.showWarning("Le bus arrive".localized(), subTitle: "Dépêchez vous, vous allez le rater !".localized(), closeButtonTitle: "OK".localized(), duration: 10)
            }
            else {
                alertView.addButton("A l'heure du départ".localized(), action: { () -> Void in
                    self.scheduleNotification(self.departuresList[indexPath.row].timestamp, before: 0, line: self.departuresList[indexPath.row].line, direction: self.departuresList[indexPath.row].direction)
                    
                })
                if Int(self.departuresList[indexPath.row].leftTime)! > 5 {
                    alertView.addButton("5 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(self.departuresList[indexPath.row].timestamp, before: 5, line: self.departuresList[indexPath.row].line, direction: self.departuresList[indexPath.row].direction)
                    })
                }
                if Int(self.departuresList[indexPath.row].leftTime)! > 10 {
                    alertView.addButton("10 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(self.departuresList[indexPath.row].timestamp, before: 10, line: self.departuresList[indexPath.row].line, direction: self.departuresList[indexPath.row].direction)
                    })
                }
                alertView.addButton("Autre".localized(), action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombre de minutes".localized())
                    txt.keyboardType = .NumberPad
                    txt.becomeFirstResponder()
                    customValueAlert.addButton("Rappeler".localized(), action: { () -> Void in
                        if Int(self.departuresList[indexPath.row].leftTime)! < Int(txt.text!)! {
                            customValueAlert.hideView()
                            SCLAlertView().showError("Il y a un problème".localized(), subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized(), closeButtonTitle: "OK".localized(), duration: 10)
                            
                        }
                        else {
                            self.scheduleNotification(self.departuresList[indexPath.row].timestamp, before: Int(txt.text!)!, line: self.departuresList[indexPath.row].line, direction: self.departuresList[indexPath.row].direction)
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
        
        let voirToutAction = UITableViewRowAction(style: .Default, title: "Voir tout".localized()) { (action, indexPath) in
            self.performSegueWithIdentifier("showAllDepartures", sender: indexPath)
        }
        voirToutAction.backgroundColor = UIColor.flatGreenColor()
        return [voirToutAction, timerAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if loading == true {
            return false
        }
        else if offline && indexPath.section == 0 {
            return false
        }
        else if offline && indexPath.section == 1 && noMoreTransport {
            return false
        }
        else if !offline && indexPath.section == 0 && noMoreTransport {
            return false
        }
        else if departuresList[indexPath.row].leftTime == "no more" {
            return false
        }
        return true
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
        else if indexPath.section == 0 && offline {
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Mode offline".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Les horaires peuvent être sujets à modification".localized()
            let icone = FAKFontAwesome.globeIconWithSize(50)
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if offline && indexPath.section == 1 && noMoreTransport {
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Service terminé".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arrêt.".localized()
            let icone = FAKFontAwesome.busIconWithSize(50)
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if !offline && indexPath.section == 0 && noMoreTransport {
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Service terminé".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arrêt.".localized()
            let icone = FAKFontAwesome.busIconWithSize(50)
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath) as! DeparturesTableViewCell
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = departuresList[indexPath.row].line
            labelPictoLigne.textAlignment = .Center
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                labelPictoLigne.textColor = departuresList[indexPath.row].lineColor
                labelPictoLigne.layer.borderColor = departuresList[indexPath.row].lineColor.CGColor
            }
            else {
                if ContrastColorOf(departuresList[indexPath.row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                    labelPictoLigne.textColor = departuresList[indexPath.row].lineBackgroundColor
                    labelPictoLigne.layer.borderColor = departuresList[indexPath.row].lineBackgroundColor.CGColor
                }
                else {
                    labelPictoLigne.textColor = departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2)
                    labelPictoLigne.layer.borderColor = departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2).CGColor
                }
                
            }
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.linePictogram.image = image
            cell.directionLabel.text = departuresList[indexPath.row].direction
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.directionLabel.textColor = departuresList[indexPath.row].lineColor
                cell.leftTimeLabel.textColor = departuresList[indexPath.row].lineColor
                cell.backgroundColor = departuresList[indexPath.row].lineBackgroundColor
            }
            else {
                if ContrastColorOf(departuresList[indexPath.row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                    cell.directionLabel.textColor = departuresList[indexPath.row].lineBackgroundColor
                    cell.leftTimeLabel.textColor = departuresList[indexPath.row].lineBackgroundColor
                }
                else {
                    cell.directionLabel.textColor = departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2)
                    cell.leftTimeLabel.textColor = departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2)
                }
                cell.backgroundColor = UIColor.flatWhiteColor()
            }
            
            
            if offline {
                cell.accessoryView = UIImageView(image: nil)
                
                if (Int(departuresList[indexPath.row].leftTime) >= 60) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.departuresList[indexPath.row].timestamp)
                    
                    cell.leftTimeLabel.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                }
                else if (departuresList[indexPath.row].leftTime == "0") {
                    let iconeBus = FAKFontAwesome.busIconWithSize(20)
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        iconeBus.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineColor)
                    }
                    else {
                        if ContrastColorOf(departuresList[indexPath.row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                            iconeBus.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor)
                        }
                        else {
                            iconeBus.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2))
                        }
                    }
                    cell.leftTimeLabel.attributedText = iconeBus.attributedString()
                }
                else {
                    cell.leftTimeLabel.text = departuresList[indexPath.row].leftTime + "'"
                }
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    iconCheveron.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineColor)
                }
                else {
                    if ContrastColorOf(departuresList[indexPath.row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                        iconCheveron.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor)
                    }
                    else {
                        iconCheveron.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2))
                    }
                    
                }
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                
                if (departuresList[indexPath.row].leftTime == "no more") {
                    cell.accessoryView = UIImageView(image: nil)
                    let iconTimes = FAKFontAwesome.timesIconWithSize(20)
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        iconTimes.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineColor)
                    }
                    else {
                        if ContrastColorOf(departuresList[indexPath.row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                            iconTimes.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor)
                        }
                        else {
                            iconTimes.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2))
                        }
                    }
                    cell.leftTimeLabel.attributedText = iconTimes.attributedString()
                }
                else if (departuresList[indexPath.row].leftTime == "&gt;1h") {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.departuresList[indexPath.row].timestamp)
                    cell.leftTimeLabel.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                }
                else if (departuresList[indexPath.row].leftTime == "0") {
                    let busIcon = FAKFontAwesome.busIconWithSize(20)
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        busIcon.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineColor)
                    }
                    else {
                        if ContrastColorOf(departuresList[indexPath.row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                            busIcon.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor)
                        }
                        else {
                            busIcon.addAttribute(NSForegroundColorAttributeName, value: departuresList[indexPath.row].lineBackgroundColor.darkenByPercentage(0.2))
                        }
                        
                    }
                    cell.leftTimeLabel.attributedText = busIcon.attributedString()
                }
                else {
                    cell.leftTimeLabel.text = departuresList[indexPath.row].leftTime + "'"
                }
            }
            
            return cell
        }
    }
}
