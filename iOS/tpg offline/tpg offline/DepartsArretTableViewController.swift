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
    var departs:JSON = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        if let dataDeparts = NSData(contentsOfURL: NSURL(string: "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode=" + (arret!.stopCode))!) {
            departs = JSON(data: dataDeparts)
            title = arret?.nomComplet
            let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
            let couleurs = JSON(data: dataCouleurs!)
            for var i = 0; i < couleurs["colors"].count; i++ {
                listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
                listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
            }
        }
        else {
            let alert = SCLAlertView()
            alert.showError("Pas d'internet", subTitle: "tpg offline n'est actuellement pas connecté à internet", closeButtonTitle: "Fermer", duration: 10).setDismissBlock({ () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        if ((AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)) != nil) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
        }
        else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return departs["departures"].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
        
        cell.backgroundColor = listeBackgroundColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        
        let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
        labelPictoLigne.text = departs["departures"][indexPath.row]["line"]["lineCode"].string!
        labelPictoLigne.textAlignment = .Center
        labelPictoLigne.textColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
        labelPictoLigne.layer.borderColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]?.CGColor
        labelPictoLigne.layer.borderWidth = 1
        let image = labelToImage(labelPictoLigne)
        cell.imageView?.image = image
        let labelAccesory = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        labelAccesory.textAlignment = .Right
        //cell.pictoLigne.text = departs["departures"][indexPath.row]["line"]["lineCode"].string!
        cell.textLabel!.text = departs["departures"][indexPath.row]["line"]["destinationName"].string
        cell.detailTextLabel!.text = ""
        cell.textLabel!.textColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        labelAccesory.textColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        
        if (departs["departures"][indexPath.row]["waitingTime"].string == "no more") {
            let iconTimes = FAKFontAwesome.timesIconWithSize(20)
            iconTimes.addAttribute(NSForegroundColorAttributeName, value: listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!])
            labelAccesory.attributedText = iconTimes.attributedString()
        }
        else if (departs["departures"][indexPath.row]["waitingTime"].string == "&gt;1h") {
            
            labelAccesory.text = ">1h"
        }
        else if (departs["departures"][indexPath.row]["waitingTime"].string == "0") {
            let iconeBus = FAKFontAwesome.busIconWithSize(20)
            iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!])
            labelAccesory.attributedText = iconeBus.attributedString()
        }
        else {
            labelAccesory.text = departs["departures"][indexPath.row]["waitingTime"].string! + "'"
        }
        cell.accessoryView = labelAccesory
        
        return cell
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
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let timerAction = BGTableViewRowActionWithImage.rowActionWithStyle(UITableViewRowActionStyle.Default, title: "Rappeler", titleColor: UIColor.blackColor(), backgroundColor: UIColor.flatYellowColor(), image: FAKIonIcons.iosTimeOutlineIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), forCellHeight: 44) { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let alertView = SCLAlertView()
            if self.departs["departures"][indexPath.row]["waitingTime"].string == "no more" {
                alertView.showError("Le service est terminé", subTitle: "Il est impossible de définir des rappels sur des lignes dont le service est terminé.", closeButtonTitle: "OK", duration: 10).setDismissBlock({ () -> Void in
                    tableView.setEditing(false, animated: true)
                })
            }
            else if self.departs["departures"][indexPath.row]["waitingTime"].string == "0" {
                alertView.showWarning("Le bus arrive", subTitle: "Dépêchez vous, vous allez le rater !", closeButtonTitle: "OK", duration: 10)
            }
            else {
                alertView.addButton("A l'heure du départ", action: { () -> Void in
                    self.scheduleNotification(self.departs["departures"][indexPath.row]["timestamp"].string!, before: 0, ligne: self.departs["departures"][indexPath.row]["line"]["lineCode"].string!, direction: self.departs["departures"][indexPath.row]["line"]["destinationName"].string!)
                    
                })
                if Int(self.departs["departures"][indexPath.row]["waitingTime"].string!)! > 5 {
                    alertView.addButton("5 min avant le départ", action: { () -> Void in
                        self.scheduleNotification(self.departs["departures"][indexPath.row]["timestamp"].string!, before: 5, ligne: self.departs["departures"][indexPath.row]["line"]["lineCode"].string!, direction: self.departs["departures"][indexPath.row]["line"]["destinationName"].string!)
                    })
                }
                if Int(self.departs["departures"][indexPath.row]["waitingTime"].string!)! > 10 {
                    alertView.addButton("10 min avant le départ", action: { () -> Void in
                        self.scheduleNotification(self.departs["departures"][indexPath.row]["timestamp"].string!, before: 10, ligne: self.departs["departures"][indexPath.row]["line"]["lineCode"].string!, direction: self.departs["departures"][indexPath.row]["line"]["destinationName"].string!)
                    })
                }
                alertView.addButton("Autre", action: { () -> Void in
                    alertView.hideView()
                    let customValueAlert = SCLAlertView()
                    let txt = customValueAlert.addTextField("Nombres de minutes")
                    txt.keyboardType = .NumberPad
                    customValueAlert.addButton("Rappeler", action: { () -> Void in
                        if Int(self.departs["departures"][indexPath.row]["waitingTime"].string!)! < Int(txt.text!)! {
                            customValueAlert.hideView()
                            SCLAlertView().showError("Il y a un problème", subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.", closeButtonTitle: "OK", duration: 10)
                            
                        }
                        else {
                            self.scheduleNotification(self.departs["departures"][indexPath.row]["timestamp"].string!, before: Int(txt.text!)!, ligne: self.departs["departures"][indexPath.row]["line"]["lineCode"].string!, direction: self.departs["departures"][indexPath.row]["line"]["destinationName"].string!)
                            customValueAlert.hideView()
                        }
                    })
                    customValueAlert.showNotice("Rappeler", subTitle: "Quand voulez-vous être notifié ?", closeButtonTitle: "Annuler")
                })
                alertView.showNotice("Rappeler", subTitle: "Quand voulez-vous être notifié ?", closeButtonTitle: "Annuler")
                tableView.setEditing(false, animated: true)
            }
        }
        return [timerAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
        reminder.alertBody = "Le tpg de la ligne " + ligne + " en direction de " + direction + " va partir dans " + String(before) + " minutes"
        reminder.alertAction = "OK"
        reminder.soundName = UILocalNotificationDefaultSoundName
        
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
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func refresh(sender:AnyObject)
    {
        if let dataDeparts = NSData(contentsOfURL: NSURL(string: "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode=" + arret.stopCode)!) {
            departs = JSON(data: dataDeparts)
        }
        else {
            let alert = UIAlertController(title: "Données non disponibles", message: "tpg offline n'est actuellement pas connecté à internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
}
