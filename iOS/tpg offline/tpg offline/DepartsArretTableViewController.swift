//
//  DepartsArretTableViewController.swift
//  tpg offline
//
//  Created by Alice on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit
import BGTableViewRowActionWithImage
import SCLAlertView

class DepartsArretTableViewController: UITableViewController {
    var arret: Arret!
    var listeDeparts: [Departs]! = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var offline = false
    var timer: NSTimer! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for i in 0 ..< couleurs["colors"].count {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
        }
        title = arret?.nomComplet
        
        refreshDeparts()
        
        if ((AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)) != nil) {
            if offline {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            else {
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"), UIBarButtonItem(image: FAKFontAwesome.mapSignsIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "showItinerary:")]
            }
        }
        else {
            if offline {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            else {
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"), UIBarButtonItem(image: FAKFontAwesome.mapSignsIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "showItinerary:")]
            }
        }
        timer = NSTimer(timeInterval: 10, target: self, selector: "repeat:", userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculerTempsRestant(timestamp: String!) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.dateFromString(timestamp)
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: time!)
        let nows: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate())
        if now.hour == nows.hour && now.minute >= nows.minute {
            return String(now.minute - nows.minute)
        }
        /*else if now.hour == nows.hour + 1 && now.minute < nows.minute {
            return String((60 - nows.minute) + now.minute)
        }*/
        else if now.hour > nows.hour {
            return String(((nows.hour - now.hour) * 60) + now.minute)
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
            let array: [String:Arret] = [arret.nomComplet : arret]
            AppValues.nomCompletsFavoris.append(arret.nomComplet)
            AppValues.arretsFavoris = array
            
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(array)
            defaults.setObject(encodedData, forKey: "arretsFavoris")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
        }
        else {
            if ((AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)) != nil) {
                AppValues.arretsFavoris.removeValueForKey(arret.nomComplet)
                AppValues.nomCompletsFavoris.removeAtIndex(AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)!)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            else {
                AppValues.arretsFavoris![arret.nomComplet] = arret
                AppValues.nomCompletsFavoris.append(arret.nomComplet)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.arretsFavoris!)
            defaults.setObject(encodedData, forKey: "arretsFavoris")
        }
    }
    
    func showItinerary(sender: AnyObject!) {
        performSegueWithIdentifier("showItinerary", sender: self)
    }
    
    func scheduleNotification(hour: String, before: Int, ligne: String, direction: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.dateFromString(hour)
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time!)
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date = cal.dateBySettingHour(now.hour, minute: now.minute - before, second: now.second, ofDate: time!, options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate = date
        if before == 0 {
            reminder.alertBody = "Le tpg de la ligne " + ligne + " en direction de " + direction + " va immédiatement"
        }
        else {
            reminder.alertBody = "Le tpg de la ligne " + ligne + " en direction de " + direction + " va partir dans " + String(before) + " minutes"
        }
        reminder.soundName = "Sound.aif"
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        print("Firing at \(now.hour):\(now.minute-before):\(now.second)")
        
        let okView = SCLAlertView()
        if before == 0 {
            okView.showSuccess("Vous serez notifié", subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.", closeButtonTitle: "OK", duration: 10)
        }
        else {
            okView.showSuccess("Vous serez notifié", subTitle: "La notification à été enregistrée et sera affichée \(before) minutes avant le départ.", closeButtonTitle: "OK", duration: 10)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        refreshDeparts()
        tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    func refreshDeparts() {
        listeDeparts = []
        if let dataDeparts = NSData(contentsOfURL: NSURL(string: "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode=" + (arret!.stopCode))!) {
            let departs = JSON(data: dataDeparts)
            
            for x in 0...departs["departures"].count-1 {
                if departs["departures"][x]["waitingTime"].string! == "no more" {
                    listeDeparts.append(Departs(
                        ligne: departs["departures"][x]["line"]["lineCode"].string!,
                        direction: departs["departures"][x]["line"]["destinationName"].string!,
                        couleur: listeColor[departs["departures"][x]["line"]["lineCode"].string!]!,
                        couleurArrierePlan: listeBackgroundColor[departs["departures"][x]["line"]["lineCode"].string!]!,
                        code: nil,
                        tempsRestant: departs["departures"][x]["waitingTime"].string!,
                        timestamp: ""
                        ))
                }
                else {
                    listeDeparts.append(Departs(
                        ligne: departs["departures"][x]["line"]["lineCode"].string!,
                        direction: departs["departures"][x]["line"]["destinationName"].string!,
                        couleur: listeColor[departs["departures"][x]["line"]["lineCode"].string!]!,
                        couleurArrierePlan: listeBackgroundColor[departs["departures"][x]["line"]["lineCode"].string!]!,
                        
                        code: String(departs["departures"][x]["departureCode"].int!),
                        tempsRestant: departs["departures"][x]["waitingTime"].string!,
                        timestamp: departs["departures"][x]["timestamp"].string!
                        ))
                }
                /*listeDeparts.append(Departs(
                 ligne: departs["departures"][x]["line"]["lineCode"].string!,
                 direction: departs["departures"][x]["line"]["destinationName"].string!,
                 couleur: listeColor[departs["departures"][x]["line"]["lineCode"].string!]!,
                 couleurArrierePlan: listeBackgroundColor[departs["departures"][x]["line"]["lineCode"].string!]!,
                 
                 code: String(departs["departures"][x]["departureCode"].int!),
                 tempsRestant: departs["departures"][x]["waitingTime"].string!,
                 timestamp: departs["departures"][x]["timestamp"].string!
                 ))*/
            }
            offline = false
        }
        else if let dataDeparts = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(arret.stopCode + "departs", ofType: "json", inDirectory: "Departs")!) {
            let departs = JSON(data: dataDeparts)
            let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
            switch day.weekday {
            case 7:
                for (_, subJson) in departs["SAM"] {
                    if calculerTempsRestant(subJson["timestamp"].string!) != "-1" {
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
                break
            case 1:
                for (_, subJson) in departs["DIM"] {
                    if calculerTempsRestant(subJson["timestamp"].string!) != "-1" {
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
                break
            default:
                for (_, subJson) in departs["LUN"] {
                    if calculerTempsRestant(subJson["timestamp"].string!) != "-1" {
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
            
            
            listeDeparts.sortInPlace({ (depart1, depart2) -> Bool in
                if Int(depart1.tempsRestant) < Int(depart2.tempsRestant) {
                    return true
                }
                return false
            })
            
            offline = true
            
        }
    }
}

extension DepartsArretTableViewController {
    // MARK: tableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if offline {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if offline && section == 0{
            return 1
        }
        return listeDeparts.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if offline && indexPath.section == 0 {
            return 60
        }
        return 44
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let timerAction = BGTableViewRowActionWithImage.rowActionWithStyle(UITableViewRowActionStyle.Default, title: "Rappeler", titleColor: UIColor.blackColor(), backgroundColor: UIColor.flatYellowColor(), image: FAKIonIcons.iosTimeOutlineIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), forCellHeight: 44) { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let icone = FAKIonIcons.iosClockIconWithSize(20)
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            icone.imageWithSize(CGSize(width: 20, height: 20))
            let alertView = SCLAlertView()
            if self.listeDeparts[indexPath.row].tempsRestant == "0" {
                alertView.showWarning("Le bus arrive", subTitle: "Dépêchez vous, vous allez le rater !", closeButtonTitle: "OK", duration: 10)
            }
            else {
                alertView.addButton("A l'heure du départ", action: { () -> Void in
                    self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: 0, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                    
                })
                if Int(self.listeDeparts[indexPath.row].tempsRestant)! > 5 {
                    alertView.addButton("5 min avant le départ", action: { () -> Void in
                        self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: 5, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                    })
                }
                if Int(self.listeDeparts[indexPath.row].tempsRestant)! > 10 {
                    alertView.addButton("10 min avant le départ", action: { () -> Void in
                        self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: 10, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                    })
                }
                alertView.addButton("Autre", action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombre de minutes")
                    txt.keyboardType = .NumberPad
                    txt.becomeFirstResponder()
                    customValueAlert.addButton("Rappeler", action: { () -> Void in
                        if Int(self.listeDeparts[indexPath.row].tempsRestant)! < Int(txt.text!)! {
                            customValueAlert.hideView()
                            SCLAlertView().showError("Il y a un problème", subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.", closeButtonTitle: "OK", duration: 10)
                            
                        }
                        else {
                            self.scheduleNotification(self.listeDeparts[indexPath.row].timestamp, before: Int(txt.text!)!, ligne: self.listeDeparts[indexPath.row].ligne, direction: self.listeDeparts[indexPath.row].direction)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler", subTitle: "Quand voulez-vous être notifié(e) ?", closeButtonTitle: "Annuler", circleIconImage: icone.imageWithSize(CGSize(width: 20, height: 20)))
                })
                alertView.showNotice("Rappeler", subTitle: "Quand voulez-vous être notifié(e) ?", closeButtonTitle: "Annuler", circleIconImage: icone.imageWithSize(CGSize(width: 20, height: 20)))
                tableView.setEditing(false, animated: true)
            }
        }
        return [timerAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if offline && indexPath.section == 0 {
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
            
            cell.backgroundColor = UIColor.flatYellowColor()
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = "Mode offline"
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.text = "Les horaires peuvent être sujets à modification"
            cell.imageView?.image = FAKFontAwesome.globeIconWithSize(50).imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = listeDeparts[indexPath.row].couleurArrierePlan
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = listeDeparts[indexPath.row].ligne
            labelPictoLigne.textAlignment = .Center
            labelPictoLigne.textColor = listeDeparts[indexPath.row].couleur
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderColor = listeDeparts[indexPath.row].couleur.CGColor
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image
            let labelAccesory = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            labelAccesory.textAlignment = .Right
            cell.textLabel!.text = listeDeparts[indexPath.row].direction
            cell.detailTextLabel!.text = ""
            cell.textLabel!.textColor = listeDeparts[indexPath.row].couleur
            labelAccesory.textColor = listeDeparts[indexPath.row].couleur
            
            if offline {
                if (Int(listeDeparts[indexPath.row].tempsRestant) >= 60) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: time!)
                    if now.minute < 10 {
                        labelAccesory.text = String(now.hour) + ":0" + String(now.minute)
                    }
                    else {
                        labelAccesory.text = String(now.hour) + ":" + String(now.minute)
                    }
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "0") {
                    let iconeBus = FAKFontAwesome.busIconWithSize(20)
                    iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
                    labelAccesory.attributedText = iconeBus.attributedString()
                }
                else {
                    labelAccesory.text = listeDeparts[indexPath.row].tempsRestant + "'"
                }
            }
            else {
                if (listeDeparts[indexPath.row].tempsRestant == "no more") {
                    let iconTimes = FAKFontAwesome.timesIconWithSize(20)
                    iconTimes.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
                    labelAccesory.attributedText = iconTimes.attributedString()
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "&gt;1h") {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: time!)
                    
                    if now.minute < 10 {
                        labelAccesory.text = String(now.hour) + ":0" + String(now.minute)
                    }
                    else {
                        labelAccesory.text = String(now.hour) + ":" + String(now.minute)
                    }
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "0") {
                    let iconeBus = FAKFontAwesome.busIconWithSize(20)
                    iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
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