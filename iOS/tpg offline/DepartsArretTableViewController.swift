//
//  DepartsArretTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit
import SCLAlertView
import ChameleonFramework
import DGElasticPullToRefresh
import MRProgress
import Google

class DepartsArretTableViewController: UITableViewController {
    var arret: Arret? = nil
    var listeDeparts: [Departs]! = []
    var listeBackgroundColor = [String:UIColor]()
    var arretsKeys: [String] = []
    var listeColor = [String:UIColor]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var offline = false
    var serviceTermine = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arretsKeys = [String](AppValues.arrets.keys)
        arretsKeys.sortInPlace({ (string1, string2) -> Bool in
            let stringA = String((AppValues.arrets[string1]?.titre)! + (AppValues.arrets[string1]?.sousTitre)!)
            let stringB = String((AppValues.arrets[string2]?.titre)! + (AppValues.arrets[string2]?.sousTitre)!)
            if stringA.lowercaseString < stringB.lowercaseString {
                return true
            }
            return false
        })
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            self!.refreshDeparts()
            self!.tableView.reloadData()
            
            self?.tableView.dg_stopLoading()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for i in 0 ..< couleurs["colors"].count {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
        }
        
        title = arret?.nomComplet
        
        tableView.backgroundColor = AppValues.primaryColor
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*if arret == nil {
            arret = AppValues.arrets[arretsKeys[0]]
        }*/
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        actualiserTheme()
        
        if arret != nil {
            var barButtonsItems: [UIBarButtonItem] = []
            
            if ((AppValues.nomCompletsFavoris.indexOf(arret!.nomComplet)) != nil) {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
            }
            else {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action:"toggleFavorite:"))
            }
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "showItinerary:"))
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "refresh:"))
            
            self.navigationItem.rightBarButtonItems = barButtonsItems
            
            if !(NSProcessInfo.processInfo().arguments.contains("-withoutAnalytics")) {
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.set(kGAIScreenName, value: "DepartsArretTableViewController-\(arret!.stopCode)")
                tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]!)
            }
            
            refresh(self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        tableView?.dg_removePullToRefresh()
    }
    
    func calculerTempsRestant(timestamp: String!) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.dateFromString(timestamp)
        let tempsTimestamp: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time!)
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: NSDate())
        if tempsTimestamp.hour == now.hour && tempsTimestamp.minute == now.minute && tempsTimestamp.second >= now.second {
            return "0"
        }
        else if tempsTimestamp.hour == now.hour && tempsTimestamp.minute - 1 == now.minute && tempsTimestamp.second <= now.second {
            return "0"
        }
        else if tempsTimestamp.hour == now.hour && tempsTimestamp.minute > now.minute {
            return String(tempsTimestamp.minute - now.minute)
        }
        else if tempsTimestamp.hour > now.hour && tempsTimestamp.hour == now.hour + 1 && tempsTimestamp.minute < now.minute {
            return String((60 - now.minute) + tempsTimestamp.minute)
        }
        else if tempsTimestamp.hour > now.hour {
            return String(((tempsTimestamp.hour - now.hour) * 60) + tempsTimestamp.minute)
        }
        else {
            return "-1"
        }
    }
    
    func labelToImage(label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func toggleFavorite(sender: AnyObject!) {
        if AppValues.arretsFavoris.isEmpty {
            let array: [String:Arret] = [arret!.nomComplet : arret!]
            AppValues.nomCompletsFavoris.append(arret!.nomComplet)
            AppValues.arretsFavoris = array
            
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(array)
            defaults.setObject(encodedData, forKey: "arretsFavoris")
        }
        else {
            if ((AppValues.nomCompletsFavoris.indexOf(arret!.nomComplet)) != nil) {
                AppValues.arretsFavoris.removeValueForKey(arret!.nomComplet)
                AppValues.nomCompletsFavoris.removeAtIndex(AppValues.nomCompletsFavoris.indexOf(arret!.nomComplet)!)
            }
            else {
                AppValues.arretsFavoris![arret!.nomComplet] = arret
                AppValues.nomCompletsFavoris.append(arret!.nomComplet)
            }
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.arretsFavoris!)
            defaults.setObject(encodedData, forKey: "arretsFavoris")
        }
        var barButtonsItems: [UIBarButtonItem] = []
        
        if ((AppValues.nomCompletsFavoris.indexOf(arret!.nomComplet)) != nil) {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
        }
        else {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
        }
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "showItinerary:"))
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "refresh:"))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems
    }
    
    func showItinerary(sender: AnyObject!) {
        performSegueWithIdentifier("showItinerary", sender: self)
    }
    
    func scheduleNotification(hour: String, before: Int, ligne: String, direction: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.dateFromString(hour)
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time!)
        
        if now.minute - before < 0 {
            now.minute += 60
            now.hour -= 1
        }
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date = cal.dateBySettingHour(now.hour, minute: now.minute - before, second: now.second, ofDate: NSDate(), options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate = date
        if before == 0 {
            reminder.alertBody = "Le tpg de la ligne ".localized() + ligne + " en direction de ".localized() + direction + " va partir immédiatement".localized()
        }
        else {
            var texte =  "Le tpg de la ligne ".localized()
            texte += ligne
            texte += " en direction de ".localized()
            texte += direction
            texte += " va partir dans ".localized()
            texte += String(before)
            texte += " minutes".localized()
            reminder.alertBody = texte
        }
        reminder.soundName = "Sound.aif"
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        print("Firing at \(now.hour):\(now.minute-before):\(now.second)")
        
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
            let routeViewController:RouteViewController = (segue.destinationViewController) as! RouteViewController
            routeViewController.arret = self.arret
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func refresh(sender:AnyObject)
    {
        CATransaction.begin()
        
        let progressBar = MRProgressOverlayView.showOverlayAddedTo(self.view.window, title: "Chargement", mode: .Indeterminate, animated: true)
        if ContrastColorOf(AppValues.secondaryColor, returnFlat: true) == FlatWhite() {
            progressBar.tintColor = AppValues.secondaryColor
            progressBar.titleLabel!.textColor = AppValues.secondaryColor
        }
        else {
            progressBar.tintColor = AppValues.textColor
            progressBar.titleLabel!.textColor = AppValues.textColor
        }
        
        CATransaction.setCompletionBlock({
            self.refreshDeparts()
            self.tableView.reloadData()
            progressBar.dismiss(true)
        })
        
        CATransaction.commit()
    }
    func refreshDeparts() {
        listeDeparts = []
        if let dataDeparts = NSData(contentsOfURL: NSURL(string: "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode=" + (arret!.stopCode))!) {
            let departs = JSON(data: dataDeparts)
            
            for (_, subjson) in departs["departures"] {
                if subjson["waitingTime"].string! == "no more" {
                    if listeColor[subjson["line"]["lineCode"].string!] == nil {
                        listeDeparts.append(Departs(
                            ligne: subjson["line"]["lineCode"].string!,
                            direction: subjson["line"]["destinationName"].string!,
                            couleur: UIColor.whiteColor(),
                            couleurArrierePlan: UIColor.flatGrayColor(),
                            code: nil,
                            tempsRestant: subjson["waitingTime"].string!,
                            timestamp: ""
                            ))
                    }
                    else {
                        listeDeparts.append(Departs(
                            ligne: subjson["line"]["lineCode"].string!,
                            direction: subjson["line"]["destinationName"].string!,
                            couleur: listeColor[subjson["line"]["lineCode"].string!]!,
                            couleurArrierePlan: listeBackgroundColor[subjson["line"]["lineCode"].string!]!,
                            code: nil,
                            tempsRestant: subjson["waitingTime"].string!,
                            timestamp: ""
                            ))
                    }
                }
                else {
                    if listeColor[subjson["line"]["lineCode"].string!] == nil {
                        listeDeparts.append(Departs(
                            ligne: subjson["line"]["lineCode"].string!,
                            direction: subjson["line"]["destinationName"].string!,
                            couleur: UIColor.whiteColor(),
                            couleurArrierePlan: UIColor.flatGrayColor(),
                            
                            code: String(subjson["departureCode"].int!),
                            tempsRestant: subjson["waitingTime"].string!,
                            timestamp: subjson["timestamp"].string!
                            ))
                    }
                    else {
                        listeDeparts.append(Departs(
                            ligne: subjson["line"]["lineCode"].string!,
                            direction: subjson["line"]["destinationName"].string!,
                            couleur: listeColor[subjson["line"]["lineCode"].string!]!,
                            couleurArrierePlan: listeBackgroundColor[subjson["line"]["lineCode"].string!]!,
                            
                            code: String(subjson["departureCode"].int!),
                            tempsRestant: subjson["waitingTime"].string!,
                            timestamp: subjson["timestamp"].string!
                            ))
                    }
                }
            }
            offline = false
            
            if listeDeparts.count == 0 {
                serviceTermine = true
            }
            else {
                serviceTermine = false
            }
        }
        else if AppValues.premium == true {
            let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
            switch day.weekday {
            case 7:
                if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    let path = dir.stringByAppendingPathComponent(arret!.stopCode + "departsDIM.json");
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        let dataDeparts = NSData(contentsOfFile: path)
                        let departs = JSON(data: dataDeparts!)
                        for (_, subJson) in departs {
                            listeDeparts.append(Departs(
                                ligne: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                couleur: listeColor[subJson["ligne"].string!]!,
                                couleurArrierePlan: listeBackgroundColor[subJson["ligne"].string!]!,
                                code: nil,
                                tempsRestant: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                            listeDeparts.last?.calculerTempsRestant()
                        }
                    }
                }
                break
            case 1:
                if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    let path = dir.stringByAppendingPathComponent(arret!.stopCode + "departsDIM.json");
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        let dataDeparts = NSData(contentsOfFile: path)
                        let departs = JSON(data: dataDeparts!)
                        for (_, subJson) in departs {
                            listeDeparts.append(Departs(
                                ligne: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                couleur: listeColor[subJson["ligne"].string!]!,
                                couleurArrierePlan: listeBackgroundColor[subJson["ligne"].string!]!,
                                code: nil,
                                tempsRestant: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                            listeDeparts.last?.calculerTempsRestant()
                        }
                    }
                }
                break
            default:
                if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    let path = dir.stringByAppendingPathComponent(arret!.stopCode + "departsLUN.json");
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        let dataDeparts = NSData(contentsOfFile: path)
                        let departs = JSON(data: dataDeparts!)
                        for (_, subJson) in departs {
                            listeDeparts.append(Departs(
                                ligne: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                couleur: listeColor[subJson["ligne"].string!]!,
                                couleurArrierePlan: listeBackgroundColor[subJson["ligne"].string!]!,
                                code: nil,
                                tempsRestant: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                            listeDeparts.last?.calculerTempsRestant()
                        }
                    }
                }
                break
            }
            
            listeDeparts = listeDeparts.filter({ (depart) -> Bool in
                if calculerTempsRestant(depart.timestamp) != "-1" {
                    return true
                }
                return false
            })
            
            listeDeparts.sortInPlace({ (depart1, depart2) -> Bool in
                if Int(depart1.tempsRestant) < Int(depart2.tempsRestant) {
                    return true
                }
                return false
            })
            
            offline = true
            
            if listeDeparts.count == 0 {
                serviceTermine = true
            }
            else {
                serviceTermine = false
            }
        }
        else {
            offline = true
            listeDeparts = []
            serviceTermine = false
        }
    }
}

extension DepartsArretTableViewController {
    // MARK: tableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if offline {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if offline && section == 0 {
            return 1
        }
        else if offline && section == 1 && serviceTermine {
            return 1
        }
        else if !offline && section == 0 && serviceTermine {
            return 1
        }
        else {
            return listeDeparts.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if offline && indexPath.section == 0 {
            return 60
        }
        else if offline && indexPath.section == 1 && serviceTermine {
            return 60
        }
        else if !offline && indexPath.section == 0 && serviceTermine {
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
            if self.listeDeparts[indexPath.row].tempsRestant == "0" {
                alertView.showWarning("Le bus arrive".localized(), subTitle: "Dépêchez vous, vous allez le rater !".localized(), closeButtonTitle: "OK".localized(), duration: 10)
            }
            else {
                alertView.addButton("A l'heure du départ".localized(), action: { () -> Void in
                    self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: 0, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                    
                })
                if Int(self.listeDeparts[indexPath.row].tempsRestant)! > 5 {
                    alertView.addButton("5 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: 5, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                    })
                }
                if Int(self.listeDeparts[indexPath.row].tempsRestant)! > 10 {
                    alertView.addButton("10 min avant le départ".localized(), action: { () -> Void in
                        self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: 10, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                    })
                }
                alertView.addButton("Autre".localized(), action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombre de minutes".localized())
                    txt.keyboardType = .NumberPad
                    txt.becomeFirstResponder()
                    customValueAlert.addButton("Rappeler".localized(), action: { () -> Void in
                        if Int(self.listeDeparts[indexPath.row].tempsRestant)! < Int(txt.text!)! {
                            customValueAlert.hideView()
                            SCLAlertView().showError("Il y a un problème".localized(), subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized(), closeButtonTitle: "OK".localized(), duration: 10)
                            
                        }
                        else {
                            self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: Int(txt.text!)!, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
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
        if offline && indexPath.section == 0 {
            return false
        }
        else if offline && indexPath.section == 1 && serviceTermine {
            return false
        }
        else if !offline && indexPath.section == 0 && serviceTermine {
            return false
        }
        else if listeDeparts[indexPath.row].tempsRestant == "no more" {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && offline {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = AppValues.secondaryColor
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
        else if offline && indexPath.section == 1 && serviceTermine {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = AppValues.secondaryColor
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
        else if !offline && indexPath.section == 0 && serviceTermine {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = AppValues.secondaryColor
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
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = listeDeparts[indexPath.row].ligne
            labelPictoLigne.textAlignment = .Center
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                labelPictoLigne.textColor = listeDeparts[indexPath.row].couleur
                labelPictoLigne.layer.borderColor = listeDeparts[indexPath.row].couleur.CGColor
            }
            else {
                if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                    labelPictoLigne.textColor = listeDeparts[indexPath.row].couleurArrierePlan
                    labelPictoLigne.layer.borderColor = listeDeparts[indexPath.row].couleurArrierePlan.CGColor
                }
                else {
                    labelPictoLigne.textColor = listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2)
                    labelPictoLigne.layer.borderColor = listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2).CGColor
                }
                
            }
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image
            let labelAccesory = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            labelAccesory.textAlignment = .Right
            cell.textLabel!.text = listeDeparts[indexPath.row].direction
            cell.detailTextLabel!.text = ""
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel!.textColor = listeDeparts[indexPath.row].couleur
                labelAccesory.textColor = listeDeparts[indexPath.row].couleur
                cell.backgroundColor = listeDeparts[indexPath.row].couleurArrierePlan
            }
            else {
                if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                    cell.textLabel!.textColor = listeDeparts[indexPath.row].couleurArrierePlan
                    labelAccesory.textColor = listeDeparts[indexPath.row].couleurArrierePlan
                }
                else {
                    cell.textLabel!.textColor = listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2)
                    labelAccesory.textColor = listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2)
                }
                cell.backgroundColor = UIColor.flatWhiteColor()
            }
            
            
            if offline {
                if (Int(listeDeparts[indexPath.row].tempsRestant) >= 60) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    
                    labelAccesory.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "0") {
                    let iconeBus = FAKFontAwesome.busIconWithSize(20)
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
                    }
                    else {
                        if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                            iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan)
                        }
                        else {
                            iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2))
                        }
                    }
                    labelAccesory.attributedText = iconeBus.attributedString()
                }
                else {
                    labelAccesory.text = listeDeparts[indexPath.row].tempsRestant + "'"
                }
            }
            else {
                if (listeDeparts[indexPath.row].tempsRestant == "no more") {
                    let iconTimes = FAKFontAwesome.timesIconWithSize(20)
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        iconTimes.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
                    }
                    else {
                        if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                            iconTimes.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan)
                        }
                        else {
                            iconTimes.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2))
                        }
                    }
                    labelAccesory.attributedText = iconTimes.attributedString()
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "&gt;1h") {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    labelAccesory.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "0") {
                    let iconeBus = FAKFontAwesome.busIconWithSize(20)
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
                    }
                    else {
                        if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                            iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan)
                        }
                        else {
                            iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2))
                        }
                        
                    }
                    labelAccesory.attributedText = iconeBus.attributedString()
                }
                else {
                    labelAccesory.text = listeDeparts[indexPath.row].tempsRestant + "'"
                }
            }
            cell.accessoryView = labelAccesory
            
            return cell
        }
    }
}