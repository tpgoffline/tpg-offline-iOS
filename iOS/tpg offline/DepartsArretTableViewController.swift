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
import SwiftDate
import Alamofire

class DepartsArretTableViewController: UITableViewController {
    var arret: Arret? = nil
    var listeDeparts: [Departs]! = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    var arretsKeys: [String] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var offline = false
    var serviceTermine = false
    var chargement: Bool = false
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
        
        refresh(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        actualiserTheme()
        
        if arret != nil {
            var barButtonsItems: [UIBarButtonItem] = []
            
            if ((AppValues.nomCompletsFavoris.indexOf(arret!.nomComplet)) != nil) {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.toggleFavorite(_:))))
            }
            else {
                barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action:#selector(DepartsArretTableViewController.toggleFavorite(_:))))
            }
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.showItinerary(_:))))
            barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.refresh(_:))))
            
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
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.toggleFavorite(_:))))
        }
        else {
            barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.toggleFavorite(_:))))
        }
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.showItinerary(_:))))
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(DepartsArretTableViewController.refresh(_:))))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems
        let navController = self.splitViewController?.viewControllers[0] as! UINavigationController
        if (navController.viewControllers[0].isKindOfClass(ArretsTableViewController)) {
            let arretTableViewController = navController.viewControllers[0] as! ArretsTableViewController
            arretTableViewController.tableView.reloadData()
        }
    }
    
    func showItinerary(sender: AnyObject!) {
        performSegueWithIdentifier("showItinerary", sender: self)
    }
    
    func scheduleNotification(hour: String, before: Int, ligne: String, direction: String) {
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
        else if segue.identifier == "showLigne" {
            let voirLigneTableViewController: VoirLigneTableViewController = (segue.destinationViewController) as! VoirLigneTableViewController
            voirLigneTableViewController.depart = listeDeparts[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func refresh(sender:AnyObject) {
        chargement = true
        tableView.reloadData()
        refreshDeparts()
    }
    func refreshDeparts() {
        listeDeparts = []
        Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": arret!.stopCode])
            .responseJSON { response in
                if let data = response.result.value {
                    let departs = JSON(data)
                    for (_, subjson) in departs["departures"] {
                        if self.listeColor[subjson["line"]["lineCode"].string!] == nil {
                            self.listeDeparts.append(Departs(
                                ligne: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                couleur: UIColor.whiteColor(),
                                couleurArrierePlan: UIColor.flatGrayColor(),
                                
                                code: String(subjson["departureCode"].intValue ?? 0),
                                tempsRestant: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                                ))
                        }
                        else {
                            self.listeDeparts.append(Departs(
                                ligne: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                couleur: self.listeColor[subjson["line"]["lineCode"].string!]!,
                                couleurArrierePlan: self.listeBackgroundColor[subjson["line"]["lineCode"].string!]!,
                                
                                code: String(subjson["departureCode"].intValue ?? 0),
                                tempsRestant: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                                ))
                        }
                    }
                    self.offline = false
                    self.tableView.allowsSelection = true
                    
                    if self.listeDeparts.count == 0 {
                        self.serviceTermine = true
                    }
                    else {
                        self.serviceTermine = false
                    }
                    self.chargement = false
                    self.tableView.reloadData()
                }
                else {
                    if AppValues.premium == true {
                        let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
                        var path = ""
                        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                            switch day.weekday {
                            case 7:
                                
                                path = dir.stringByAppendingPathComponent(self.arret!.stopCode + "departsSAM.json")
                                break
                            case 1:
                                path = dir.stringByAppendingPathComponent(self.arret!.stopCode + "departsDIM.json");
                                break
                            default:
                                path = dir.stringByAppendingPathComponent(self.arret!.stopCode + "departsLUN.json");
                                
                                break
                            }
                        }
                        
                        if NSFileManager.defaultManager().fileExistsAtPath(path) {
                            let dataDeparts = NSData(contentsOfFile: path)
                            let departs = JSON(data: dataDeparts!)
                            for (_, subJson) in departs {
                                if self.listeColor[subJson["ligne"].string!] != nil {
                                    self.listeDeparts.append(Departs(
                                        ligne: subJson["ligne"].string!,
                                        direction: subJson["destination"].string!,
                                        couleur: self.listeColor[subJson["ligne"].string!]!,
                                        couleurArrierePlan: self.listeBackgroundColor[subJson["ligne"].string!]!,
                                        code: nil,
                                        tempsRestant: "0",
                                        timestamp: subJson["timestamp"].string!
                                        ))
                                }
                                else {
                                    self.listeDeparts.append(Departs(
                                        ligne: subJson["ligne"].string!,
                                        direction: subJson["destination"].string!,
                                        couleur: UIColor.whiteColor(),
                                        couleurArrierePlan: UIColor.flatGrayColorDark(),
                                        code: nil,
                                        tempsRestant: "0",
                                        timestamp: subJson["timestamp"].string!
                                        ))
                                }
                                self.listeDeparts.last?.calculerTempsRestant()
                            }
                        }
                        
                        self.listeDeparts = self.listeDeparts.filter({ (depart) -> Bool in
                            if depart.tempsRestant != "-1" {
                                return true
                            }
                            return false
                        })
                        
                        self.listeDeparts.sortInPlace({ (depart1, depart2) -> Bool in
                            if Int(depart1.tempsRestant) < Int(depart2.tempsRestant) {
                                return true
                            }
                            return false
                        })
                        
                        self.offline = true
                        self.tableView.allowsSelection = false
                        
                        if self.listeDeparts.count == 0 {
                            self.serviceTermine = true
                        }
                        else {
                            self.serviceTermine = false
                        }
                        self.chargement = false
                        self.tableView.reloadData()
                    }
                    else {
                        self.offline = true
                        self.tableView.allowsSelection = false
                        self.listeDeparts = []
                        self.serviceTermine = false
                        self.chargement = false
                        self.tableView.reloadData()
                    }
                }
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
        if chargement == true {
            return 1
        }
        else if offline && section == 0 {
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
        if chargement == true {
            return 60
        }
        else if offline && indexPath.section == 0 {
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
        if chargement == true {
            return false
        }
        else if offline && indexPath.section == 0 {
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
        if chargement == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath) as! DepartsTableViewCell
            
            let icone = FAKFontAwesome.spinnerIconWithSize(50)
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor.flatBlueColor()
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.detailTextLabel?.textColor = UIColor.whiteColor()
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            }
            else {
                cell.backgroundColor = UIColor.whiteColor()
                cell.textLabel?.textColor = UIColor.flatBlueColor()
                cell.detailTextLabel?.textColor = UIColor.flatBlueColor()
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatBlueColor())
                
            }
            cell.textLabel?.text = "Chargement".localized()
            cell.detailTextLabel?.text = "Merci de patienter".localized()
            
            cell.imageView?.image = icone.imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if indexPath.section == 0 && offline {
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath) as! DepartsTableViewCell
            
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
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath) as! DepartsTableViewCell
            
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
            let cell = tableView.dequeueReusableCellWithIdentifier("infoArretCell", forIndexPath: indexPath) as! DepartsTableViewCell
            
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
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath) as! DepartsTableViewCell
            
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
            cell.pictoLigne.image = image
            cell.labelDirection.text = listeDeparts[indexPath.row].direction
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.labelDirection.textColor = listeDeparts[indexPath.row].couleur
                cell.labelTempsRestant.textColor = listeDeparts[indexPath.row].couleur
                cell.backgroundColor = listeDeparts[indexPath.row].couleurArrierePlan
            }
            else {
                if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                    cell.labelDirection.textColor = listeDeparts[indexPath.row].couleurArrierePlan
                    cell.labelTempsRestant.textColor = listeDeparts[indexPath.row].couleurArrierePlan
                }
                else {
                    cell.labelDirection.textColor = listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2)
                    cell.labelTempsRestant.textColor = listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2)
                }
                cell.backgroundColor = UIColor.flatWhiteColor()
            }
            
            
            if offline {
                cell.accessoryView = UIImageView(image: nil)
                
                if (Int(listeDeparts[indexPath.row].tempsRestant) >= 60) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    
                    cell.labelTempsRestant.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
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
                    cell.labelTempsRestant.attributedText = iconeBus.attributedString()
                }
                else {
                    cell.labelTempsRestant.text = listeDeparts[indexPath.row].tempsRestant + "'"
                }
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    iconCheveron.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleur)
                }
                else {
                    if ContrastColorOf(listeDeparts[indexPath.row].couleurArrierePlan, returnFlat: true) == FlatWhite() {
                        iconCheveron.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan)
                    }
                    else {
                        iconCheveron.addAttribute(NSForegroundColorAttributeName, value: listeDeparts[indexPath.row].couleurArrierePlan.darkenByPercentage(0.2))
                    }
                    
                }
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                
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
                    cell.labelTempsRestant.attributedText = iconTimes.attributedString()
                }
                else if (listeDeparts[indexPath.row].tempsRestant == "&gt;1h") {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    cell.labelTempsRestant.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
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
                    cell.labelTempsRestant.attributedText = iconeBus.attributedString()
                }
                else {
                    cell.labelTempsRestant.text = listeDeparts[indexPath.row].tempsRestant + "'"
                }
            }
            
            return cell
        }
    }
}