//
//  DeparturesTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import Chameleon
import Alamofire
import NVActivityIndicatorView
import WatchConnectivity
import FontAwesomeKit
import UserNotifications
import Crashlytics

class DeparturesTableViewController: UITableViewController {
    var stop: Stop? = nil
    var departuresList: [Departures]! = []
    let defaults = UserDefaults.standard
    var offline = false
    var noMoreTransport = false
    var loading: Bool = false
    var notDownloaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if stop == nil {
            stop = AppValues.stops[[String](AppValues.stops.keys).sorted()[0]]
        }
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refresh()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        title = stop?.fullName
        
        tableView.backgroundColor = AppValues.primaryColor
        
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        refreshTheme()
        
        if stop != nil {
            var barButtonsItems: [UIBarButtonItem] = []
            
            if ((AppValues.fullNameFavoritesStops.index(of: stop!.fullName)) != nil) {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.toggleFavorite(_:))))
            }
            else {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action:#selector(DeparturesTableViewController.toggleFavorite(_:))))
            }
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.showItinerary(_:))))
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.refresh)))
            
            self.navigationItem.rightBarButtonItems = barButtonsItems
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        tableView?.dg_removePullToRefresh()
    }
    
    func labelToImage(_ label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func toggleFavorite(_ sender: Any!) {
        if AppValues.favoritesStops.isEmpty {
            let array: [String:Stop] = [stop!.fullName: stop!]
            AppValues.fullNameFavoritesStops.append(stop!.fullName)
            AppValues.favoritesStops = array
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: array)
            defaults.set(encodedData, forKey: "favoritesStops")
        }
        else {
            if ((AppValues.fullNameFavoritesStops.index(of: stop!.fullName)) != nil) {
                AppValues.favoritesStops.removeValue(forKey: stop!.fullName)
                AppValues.fullNameFavoritesStops.remove(at: AppValues.fullNameFavoritesStops.index(of: stop!.fullName)!)
            }
            else {
                AppValues.favoritesStops![stop!.fullName] = stop
                AppValues.fullNameFavoritesStops.append(stop!.fullName)
            }
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: AppValues.favoritesStops!)
            defaults.set(encodedData, forKey: "favoritesStops")
        }
        
        if WCSession.isSupported() {
            do {
                var a: [String:[String:Any]] = [:]
                for (x, y) in AppValues.favoritesStops {
                    a[x] = y.toDictionnary()
                }
                var offlineDepartures: [String:String] = [:]
                var path = ""
                for (_, y) in AppValues.favoritesStops {
                    var json = JSON(data: "{}".data(using: String.Encoding.utf8)!)
                    var departuresArray: [String:String] = [:]
                    let dir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
                    path = dir.appendingPathComponent(y.stopCode + "departsSAM.json").absoluteString
                    
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try departuresArray["SAM"] = String(contentsOfFile: path)
                        } catch {
                            print("Reading of \(path) is failed")
                        }
                    }
                    
                    path = dir.appendingPathComponent(y.stopCode + "departsDIM.json").absoluteString
                    
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try departuresArray["DIM"] = String(contentsOfFile: path)
                        } catch {
                            print("Reading of \(path) is failed")
                        }
                    }
                    
                    path = dir.appendingPathComponent(y.stopCode + "departsLUN.json").absoluteString
                    
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try departuresArray["LUN"] = String(contentsOfFile: path)
                        } catch {
                            print("Reading of \(path) is failed")
                        }
                    }
                    
                    json.dictionaryObject = departuresArray
                    offlineDepartures[y.stopCode] = json.rawString() ?? ""
                    
                }
                try WatchSessionManager.sharedManager.updateApplicationContext(["favoritesStops": NSKeyedArchiver.archivedData(withRootObject: a) as Any, "offlineDepartures": offlineDepartures as Any])
                
            } catch {
                AppValues.logger.error("Update WatchConnectivity with application context failed")
            }
        }
        
        var barButtonsItems: [UIBarButtonItem] = []
        
        if ((AppValues.fullNameFavoritesStops.index(of: stop!.fullName)) != nil) {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.toggleFavorite(_:))))
        }
        else {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.toggleFavorite(_:))))
        }
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.showItinerary(_:))))
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(DeparturesTableViewController.refresh)))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems
        let navController = self.splitViewController?.viewControllers[0] as! UINavigationController
        if (navController.viewControllers[0].isKind(of: StopsTableViewController.self)) {
            let arretTableViewController = navController.viewControllers[0] as! StopsTableViewController
            arretTableViewController.tableView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "showLigne" && departuresList[(tableView.indexPathForSelectedRow! as NSIndexPath).row].leftTime == "no more") {
            return false
        }
        else {
            return true
        }
    }
    
    func showItinerary(_ sender: Any!) {
        performSegue(withIdentifier: "showItinerary", sender: self)
    }
    
    func scheduleNotification(_ hour: String, before: Int, line: String, direction: String) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    let content = UNMutableNotificationContent()
                    if before == 0 {
                        content.title = "Départ immédiat !".localized()
                        content.body = "Le tpg de la line ".localized() + line + " en direction de ".localized() + direction + " va partir immédiatement".localized()
                    }
                    else {
                        content.title = "Départ dans ".localized() + String(before) + " minutes".localized()
                        var text =  "Le tpg de la line ".localized()
                        text += line
                        text += " en direction de ".localized()
                        text += direction
                        text += " va partir dans ".localized()
                        text += String(before)
                        text += " minutes".localized()
                        content.body = text
                    }
                    content.categoryIdentifier = "departureNotifications"
                    content.userInfo = [:]
                    content.sound = UNNotificationSound.default()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    var time = dateFormatter.date(from: hour)
                    time!.addTimeInterval(Double(before) * -1.0)
                    let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)
                    
                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in
                        if error == nil {
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
                        } else {
                            Crashlytics.sharedInstance().recordError(error!)
                            SCLAlertView().showError("Impossible d'enregistrer la notification", subTitle: "L'erreur a été reportée au développeur. Merci de réessayer.", closeButtonTitle: "OK", duration: 30)
                        }
                    })
                } else {
                    SCLAlertView().showError("Notifications désactivées", subTitle: "Merci d'activer les notifications dans les réglages", closeButtonTitle: "OK", duration: 30)
                }
            }
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            var time = dateFormatter.date(from: hour)
            time!.addTimeInterval(Double(before) * -1.0)
            let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)
            
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())
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
            
            UIApplication.shared.scheduleLocalNotification(reminder)
            
            AppValues.logger.debug("Firing at \(now.hour):\(now.minute!-before):\(now.second)")
            
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
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItinerary" {
            let routeViewController: RouteToStopViewController = (segue.destination) as! RouteToStopViewController
            routeViewController.stop = self.stop
        }
        else if segue.identifier == "showLigne" {
            let voirLigneTableViewController: ThermometerTableViewController = (segue.destination) as! ThermometerTableViewController
            voirLigneTableViewController.departure = departuresList[((tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
        }
        else if segue.identifier == "showAllDepartures" {
            let indexPath = sender as! IndexPath
            let voirTousLesDepartsViewController: SeeAllDeparturesViewController = (segue.destination) as! SeeAllDeparturesViewController
            voirTousLesDepartsViewController.stop = self.stop!
            voirTousLesDepartsViewController.line = self.departuresList[(indexPath as NSIndexPath).row].line
            voirTousLesDepartsViewController.direction = self.departuresList[(indexPath as NSIndexPath).row].direction
            voirTousLesDepartsViewController.destinationCode = self.departuresList[(indexPath as NSIndexPath).row].destinationCode
        }
    }
    
    func refresh() {
        self.loading = true
        self.notDownloaded = false
        self.tableView.reloadData()
        departuresList = []
        Alamofire.request("http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": stop!.stopCode])
            .responseJSON { response in
                if let data = response.result.value {
                    let departs = JSON(data)
                    for (_, subjson) in departs["departures"] {
                        if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                            self.departuresList.append(Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: UIColor.white,
                                lineBackgroundColor: UIColor.flatGray(),
                                
                                code: String(subjson["departureCode"].int ?? 0),
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
                                
                                code: String(subjson["departureCode"].int ?? 0),
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
                    let day = Calendar.current.dateComponents([.weekday], from: Date())
                    var path: URL
                    let dir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
                    switch day.weekday! {
                    case 7:
                        path = dir.appendingPathComponent(self.stop!.stopCode + "departsSAM.json")
                        break
                    case 1:
                        path = dir.appendingPathComponent(self.stop!.stopCode + "departsDIM.json");
                        break
                    default:
                        path = dir.appendingPathComponent(self.stop!.stopCode + "departsLUN.json");
        
                        break
                    }
                    
                    do {
                        let departuresJSONString = try NSString(contentsOf: path, encoding: String.Encoding.utf8.rawValue)
                        
                        let departs = JSON(data: departuresJSONString.data(using: String.Encoding.utf8.rawValue)!)
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
                                    lineColor: UIColor.white,
                                    lineBackgroundColor: UIColor.flatGrayColorDark(),
                                    code: nil,
                                    leftTime: "0",
                                    timestamp: subJson["timestamp"].string!
                                ))
                            }
                            self.departuresList.last?.calculerTempsRestant()
                        }
                        self.departuresList = self.departuresList.filter({ (depart) -> Bool in
                            if depart.leftTime != "-1" {
                                return true
                            }
                            return false
                        })
                        
                        self.departuresList.sort(by: { (depart1, depart2) -> Bool in
                            if Int(depart1.leftTime)! < Int(depart2.leftTime)! {
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
                    catch {
                        self.offline = true
                        self.tableView.allowsSelection = false
                        self.departuresList = []
                        self.noMoreTransport = false
                        self.loading = false
                        self.notDownloaded = true
                        self.tableView.reloadData()
                        self.tableView.dg_stopLoading()
                    }
                }
        }
    }
}

extension DeparturesTableViewController {
    // MARK: tableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if loading == true {
            return 1
        }
        else if offline || notDownloaded {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true {
            return 1
        }
        else if offline && notDownloaded {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if loading == true {
            return 60
        }
        else if offline && notDownloaded {
            return 60
        }
        else if offline && (indexPath as NSIndexPath).section == 0 {
            return 60
        }
        else if offline && (indexPath as NSIndexPath).section == 1 && noMoreTransport {
            return 60
        }
        else if !offline && (indexPath as NSIndexPath).section == 0 && noMoreTransport {
            return 60
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let timerAction = UITableViewRowAction(style: .default, title: "Rappeler".localized()) { (action, indexPath) in
            let icone = FAKIonIcons.iosClockIcon(withSize: 20)!
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
            icone.image(with: CGSize(width: 20, height: 20))
            let alertView = SCLAlertView()
            if self.departuresList[(indexPath as NSIndexPath).row].leftTime == "0" {
                alertView.showWarning("Le bus arrive".localized(), subTitle: "Dépêchez vous, vous allez le rater !".localized(), closeButtonTitle: "OK".localized(), duration: 10)
            }
            else {
                alertView.addButton("A l'heure du départ".localized(), action: { () -> Void in
                    self.scheduleNotification(self.departuresList[(indexPath as NSIndexPath).row].timestamp, before: 0, line: self.departuresList[(indexPath as NSIndexPath).row].line, direction: self.departuresList[(indexPath as NSIndexPath).row].direction)
                    
                })
                if Int(self.departuresList[(indexPath as NSIndexPath).row].leftTime)! > 5 {
                    alertView.addButton("5 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(self.departuresList[(indexPath as NSIndexPath).row].timestamp, before: 5, line: self.departuresList[(indexPath as NSIndexPath).row].line, direction: self.departuresList[(indexPath as NSIndexPath).row].direction)
                    })
                }
                if Int(self.departuresList[(indexPath as NSIndexPath).row].leftTime)! > 10 {
                    alertView.addButton("10 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(self.departuresList[(indexPath as NSIndexPath).row].timestamp, before: 10, line: self.departuresList[(indexPath as NSIndexPath).row].line, direction: self.departuresList[(indexPath as NSIndexPath).row].direction)
                    })
                }
                alertView.addButton("Autre".localized(), action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombre de minutes".localized())
                    txt.keyboardType = .numberPad
                    txt.becomeFirstResponder()
                    customValueAlert.addButton("Rappeler".localized(), action: { () -> Void in
                        if Int(self.departuresList[(indexPath as NSIndexPath).row].leftTime)! < Int(txt.text!)! {
                            customValueAlert.hideView()
                            SCLAlertView().showError("Il y a un problème".localized(), subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized(), closeButtonTitle: "OK".localized(), duration: 10)
                            
                        }
                        else {
                            self.scheduleNotification(self.departuresList[(indexPath as NSIndexPath).row].timestamp, before: Int(txt.text!)!, line: self.departuresList[(indexPath as NSIndexPath).row].line, direction: self.departuresList[(indexPath as NSIndexPath).row].direction)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler".localized(), subTitle: "Quand voulez-vous être notifié(e) ?".localized(), closeButtonTitle: "Annuler".localized(), circleIconImage: icone.image(with: CGSize(width: 20, height: 20)))
                })
                alertView.showNotice("Rappeler".localized(), subTitle: "Quand voulez-vous être notifié(e) ?".localized(), closeButtonTitle: "Annuler".localized(), circleIconImage: icone.image(with: CGSize(width: 20, height: 20)))
                tableView.setEditing(false, animated: true)
            }
        }
        timerAction.backgroundColor = UIColor.flatBlue()
        
        let voirToutAction = UITableViewRowAction(style: .default, title: "Voir tout".localized()) { (action, indexPath) in
            self.performSegue(withIdentifier: "showAllDepartures", sender: indexPath)
        }
        voirToutAction.backgroundColor = UIColor.flatGreen()
        return [voirToutAction, timerAction]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if loading == true {
            return false
        }
        else if offline && notDownloaded {
            return false
        }
        else if offline && (indexPath as NSIndexPath).section == 0 {
            return false
        }
        else if offline && (indexPath as NSIndexPath).section == 1 && noMoreTransport {
            return false
        }
        else if !offline && (indexPath as NSIndexPath).section == 0 && noMoreTransport {
            return false
        }
        else if departuresList[(indexPath as NSIndexPath).row].leftTime == "no more" {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! loadingCellTableViewCell
            
            cell.activityIndicator.stopAnimating()
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor.flatBlue()
                cell.titleLabel?.textColor = UIColor.white
                cell.subTitleLabel?.textColor = UIColor.white
                cell.activityIndicator.color = UIColor.white
            }
            else {
                cell.backgroundColor = UIColor.white
                cell.titleLabel?.textColor = UIColor.flatBlue()
                cell.subTitleLabel?.textColor = UIColor.flatBlue()
                cell.activityIndicator.color = UIColor.flatBlue()
            }
            cell.titleLabel?.text = "Chargement".localized()
            cell.subTitleLabel?.text = "Merci de patienter".localized()
            cell.accessoryView = nil
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
        else if (indexPath as NSIndexPath).section == 0 && offline {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Mode offline".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Les horaires peuvent être sujets à modification".localized()
            let icone = FAKFontAwesome.globeIcon(withSize: 50)!
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.image(with: CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if offline && notDownloaded && (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Non téléchargé".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Vous pouvez télécharger les départs dans les paramètres afin d'y avoir accès en mode hors-ligne.".localized()
            let icone = FAKFontAwesome.downloadIcon(withSize: 50)!
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.image(with: CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if offline && (indexPath as NSIndexPath).section == 1 && noMoreTransport {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Service terminé".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arrêt.".localized()
            let icone = FAKFontAwesome.busIcon(withSize: 50)!
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.image(with: CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if !offline && (indexPath as NSIndexPath).section == 0 && noMoreTransport {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)
            
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Service terminé".localized()
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arrêt.".localized()
            let icone = FAKFontAwesome.busIcon(withSize: 50)!
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.imageView?.image = icone.image(with: CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "departArretCell", for: indexPath) as! DeparturesTableViewCell
            
            var lineColor = AppValues.textColor
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                lineColor = departuresList[(indexPath as NSIndexPath).row].lineColor
            }
            else {
                if ContrastColorOf(departuresList[(indexPath as NSIndexPath).row].lineBackgroundColor, returnFlat: true) == FlatWhite() {
                    lineColor = departuresList[(indexPath as NSIndexPath).row].lineBackgroundColor
                }
                else {
                    lineColor = departuresList[(indexPath as NSIndexPath).row].lineBackgroundColor.darken(byPercentage: 0.2)
                }
            }
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = departuresList[(indexPath as NSIndexPath).row].line
            labelPictoLigne.textAlignment = .center
            labelPictoLigne.textColor = lineColor
            labelPictoLigne.layer.borderColor = lineColor!.cgColor
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.linePictogram.image = image
            cell.directionLabel.text = departuresList[(indexPath as NSIndexPath).row].direction
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = departuresList[(indexPath as NSIndexPath).row].lineBackgroundColor
            }
            else {
                cell.backgroundColor = UIColor.flatWhite()
            }
            
            cell.directionLabel.textColor = lineColor
            cell.leftTimeLabel.textColor = lineColor
            
            if offline {
                cell.accessoryView = UIImageView(image: nil)
                
                if (Int(departuresList[(indexPath as NSIndexPath).row].leftTime)! >= 60) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.date(from: self.departuresList[(indexPath as NSIndexPath).row].timestamp)
                    
                    cell.leftTimeLabel.text = DateFormatter.localizedString(from: time!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
                }
                else if (departuresList[(indexPath as NSIndexPath).row].leftTime == "0") {
                    let iconeBus = FAKFontAwesome.busIcon(withSize: 20)!
                    iconeBus.addAttribute(NSForegroundColorAttributeName, value: lineColor)
                    cell.leftTimeLabel.attributedText = iconeBus.attributedString()
                }
                else {
                    cell.leftTimeLabel.text = departuresList[(indexPath as NSIndexPath).row].leftTime + "'"
                }
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 15)!
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: lineColor)
                cell.accessoryView = UIImageView(image: iconCheveron.image(with: CGSize(width: 20, height: 20)))
                
                if (departuresList[(indexPath as NSIndexPath).row].leftTime == "no more") {
                    cell.accessoryView = UIImageView(image: nil)
                    let iconTimes = FAKFontAwesome.timesIcon(withSize: 20)!
                    iconTimes.addAttribute(NSForegroundColorAttributeName, value: lineColor)
                    cell.leftTimeLabel.attributedText = iconTimes.attributedString()
                }
                else if (departuresList[(indexPath as NSIndexPath).row].leftTime == "&gt;1h") {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.date(from: self.departuresList[(indexPath as NSIndexPath).row].timestamp)
                    cell.leftTimeLabel.text = DateFormatter.localizedString(from: time!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
                }
                else if (departuresList[(indexPath as NSIndexPath).row].leftTime == "0") {
                    let busIcon = FAKFontAwesome.busIcon(withSize: 20)!
                    busIcon.addAttribute(NSForegroundColorAttributeName, value: lineColor)
                    cell.leftTimeLabel.attributedText = busIcon.attributedString()
                }
                else {
                    cell.leftTimeLabel.text = departuresList[(indexPath as NSIndexPath).row].leftTime + "'"
                }
            }
            
            return cell
        }
    }
}
