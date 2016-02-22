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
import BGTableViewRowActionWithImage
import SCLAlertView
import ChameleonFramework
import DGElasticPullToRefresh
import MRProgress

class DepartsArretTableViewController: UITableViewController {
    var arret: Arret!
    var listeDeparts: [Departs]! = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var offline = false
    var serviceTermine = false
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let loadingView = DGElasticPullToRefreshLoadingViewCircle()
		loadingView.tintColor = AppValues.textColor
		
		tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
			
			self!.refresh(loadingView)
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
		
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        tableView.backgroundColor = AppValues.primaryColor
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
		
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
        tableView.backgroundColor = AppValues.primaryColor
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
		
		refresh(self)
		
		var barButtonsItems: [UIBarButtonItem] = []
		
		if ((AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)) != nil) {
			barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		else {
			barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		if !offline {
			barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "showItinerary:"))
		}
		barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "refresh:"))
		
		self.navigationItem.rightBarButtonItems = barButtonsItems
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
	
	deinit {
		tableView.dg_removePullToRefresh()
	}
	
    func calculerTempsRestant(timestamp: String!) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.dateFromString(timestamp)
        let tempsTimestamp: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time!)
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: NSDate())
        if tempsTimestamp.hour == now.hour && tempsTimestamp.minute > now.minute {
            return String(tempsTimestamp.minute - now.minute)
        }
		else if tempsTimestamp.hour > now.hour && tempsTimestamp.hour == now.hour + 1 && tempsTimestamp.minute < now.minute {
			return String((60 - now.minute) + tempsTimestamp.minute)
		}
        else if tempsTimestamp.hour > now.hour {
            return String(((tempsTimestamp.hour - now.hour) * 60) + tempsTimestamp.minute)
        }
        else if tempsTimestamp.hour == now.hour && tempsTimestamp.minute == now.minute && tempsTimestamp.second >= now.second {
            return "0"
        }
		else if tempsTimestamp.hour == now.hour && tempsTimestamp.minute - 1 == now.minute && tempsTimestamp.second <= now.second {
			return "0"
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
        }
        else {
            if ((AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)) != nil) {
                AppValues.arretsFavoris.removeValueForKey(arret.nomComplet)
                AppValues.nomCompletsFavoris.removeAtIndex(AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)!)
            }
            else {
                AppValues.arretsFavoris![arret.nomComplet] = arret
                AppValues.nomCompletsFavoris.append(arret.nomComplet)
            }
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.arretsFavoris!)
            defaults.setObject(encodedData, forKey: "arretsFavoris")
        }
		var barButtonsItems: [UIBarButtonItem] = []
		
		if ((AppValues.nomCompletsFavoris.indexOf(arret.nomComplet)) != nil) {
			barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		else {
			barButtonsItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		if !offline {
			barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.androidWalkIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "showItinerary:"))
		}
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
            reminder.alertBody = "Le tpg de la ligne \(ligne) en direction de \(direction) va partir immédiatement".localized()
        }
        else {
            reminder.alertBody = "Le tpg de la ligne \(ligne) en direction de \(direction) va partir dans \(before) minutes".localized()
        }
        reminder.soundName = "Sound.aif"
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        print("Firing at \(now.hour):\(now.minute-before):\(now.second)")
        
        let okView = SCLAlertView()
        if before == 0 {
            okView.showSuccess("Vous serez notifié".localized(), subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized(), closeButtonTitle: "OK", duration: 10)
        }
        else {
            okView.showSuccess("Vous serez notifié".localized(), subTitle: "La notification à été enregistrée et sera affichée \(before) minutes avant le départ.".localized(), closeButtonTitle: "OK", duration: 10)
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
		
		let progressBar = MRProgressOverlayView.showOverlayAddedTo(self.view, title: "Chargement", mode: .Indeterminate, animated: true)
		progressBar.tintColor = AppValues.secondaryColor
		progressBar.titleLabel.textColor = AppValues.secondaryColor
		
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
            offline = false
        }
		else {
			let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
			switch day.weekday {
			case 7:
				if let dataDeparts = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(arret.stopCode + "departsSAM", ofType: "json", inDirectory: "Departs")!) {
					let departs = JSON(data: dataDeparts)
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
				break
			case 1:
				if let dataDeparts = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(arret.stopCode + "departsDIM", ofType: "json", inDirectory: "Departs")!) {
					let departs = JSON(data: dataDeparts)
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
				break
			default:
				if let dataDeparts = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(arret.stopCode + "departsLUN", ofType: "json", inDirectory: "Departs")!) {
					let departs = JSON(data: dataDeparts)
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
		}
		if listeDeparts.count == 0 {
            serviceTermine = true
        }
        else {
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
        let timerAction = BGTableViewRowActionWithImage.rowActionWithStyle(UITableViewRowActionStyle.Default, title: "Rappeler", titleColor: UIColor.blackColor(), backgroundColor: UIColor.flatYellowColor(), image: FAKIonIcons.iosTimeOutlineIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), forCellHeight: 44) { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
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
            
            cell.backgroundColor = UIColor.flatYellowColor()
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = "Mode offline".localized()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.text = "Les horaires peuvent être sujets à modification".localized()
            cell.imageView?.image = FAKFontAwesome.globeIconWithSize(50).imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if offline && indexPath.section == 1 && serviceTermine {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = UIColor.flatYellowColor()
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = "Service terminé".localized()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arret.".localized()
            cell.imageView?.image = FAKFontAwesome.busIconWithSize(50).imageWithSize(CGSize(width: 50, height: 50))
            cell.accessoryView = nil
            return cell
        }
        else if !offline && indexPath.section == 0 && serviceTermine {
            let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath)
            
            cell.backgroundColor = UIColor.flatRedColor()
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = "Service terminé"
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arret.".localized()
            cell.imageView?.image = FAKFontAwesome.busIconWithSize(50).imageWithSize(CGSize(width: 50, height: 50))
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
					
                    labelAccesory.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
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
                    let time = NSDateFormatter.dateFromString(self.listeDeparts[indexPath.row].timestamp)
                    labelAccesory.text = NSDateFormatter.localizedStringFromDate(time!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
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