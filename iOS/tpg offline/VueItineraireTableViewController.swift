//
//  VueItineraireTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView
import SwiftDate

class VueItineraireTableViewController: UITableViewController {
	
	var compteur = 0
	var listeBackgroundColor = [String:UIColor]()
	var listeColor = [String:UIColor]()
	var listeHeures = [NSDate]()
	let defaults = NSUserDefaults.standardUserDefaults()
	var favoris = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
		let couleurs = JSON(data: dataCouleurs!)
		for i in 0 ..< couleurs["colors"].count {
			listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
			listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
		}
		
		var listeItems: [UIBarButtonItem] = []
		
		if AppValues.premium == true {
		for x in AppValues.favorisItineraires {
			if x[0].nomComplet == ItineraireEnCours.itineraire.depart?.nomComplet && x[1].nomComplet == ItineraireEnCours.itineraire.arrivee?.nomComplet {
				favoris = true
				break
			}
		}
		if favoris {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(VueItineraireTableViewController.toggleFavorite(_:))))
		}
		else {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(VueItineraireTableViewController.toggleFavorite(_:))))
		}
		}
		self.navigationItem.rightBarButtonItems = listeItems
		tableView.backgroundColor = AppValues.primaryColor
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		actualiserTheme()
		
		tableView.backgroundColor = AppValues.primaryColor
		tableView.reloadData()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return ItineraireEnCours.json["connections"][compteur]["sections"].count
	}
	
	func labelToImage(label: UILabel!) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
		label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
		
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("itineraireCell", forIndexPath: indexPath) as! ItineraireTableViewCell
		
		var couleurTexte = UIColor.whiteColor()
		
		if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["walk"].type == .Null {
			
            cell.ligneLabel.text = "Ligne " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
            
            var icone = FAKIonIcons.androidTrainIconWithSize(24)
            switch ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["categoryCode"].intValue {
            case 6:
                icone = FAKIonIcons.androidBusIconWithSize(24)
                break
                
            case 4:
                icone = FAKIonIcons.androidBoatIconWithSize(24)
                break
                
            case 9:
                icone = FAKIonIcons.androidSubwayIconWithSize(24)
                break
                
            default:
                break
            }
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.backgroundColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                
                if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["operator"].stringValue == "TPG" {
                    cell.backgroundColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]
                    couleurTexte = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                    
                    let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                    labelPictoLigne.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
                    labelPictoLigne.textAlignment = .Center
                    labelPictoLigne.textColor = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                    labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                    labelPictoLigne.layer.borderColor = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.CGColor
                    labelPictoLigne.layer.borderWidth = 1
                    let image = labelToImage(labelPictoLigne)
                    for x in cell.iconeImageView.constraints {
                        if x.identifier == "iconeImageViewHeight" {
                            x.constant = 24
                        }
                    }
                    cell.iconeImageView.image = image
                }
                else {
                    cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 21, height: 21))
                }
            }
            else {
                couleurTexte = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                icone.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.93, green:0, blue:0.01, alpha:1))
                cell.backgroundColor = AppValues.primaryColor
                
                if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["operator"].stringValue == "TPG" {
                    if ContrastColorOf(listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!, returnFlat: true) == FlatWhite() {
                        cell.backgroundColor = UIColor.whiteColor()
                        couleurTexte = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                        let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                        labelPictoLigne.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
                        labelPictoLigne.textAlignment = .Center
                        labelPictoLigne.textColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                        labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                        labelPictoLigne.layer.borderColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.CGColor
                        labelPictoLigne.layer.borderWidth = 1
                        
                        let image = labelToImage(labelPictoLigne)
                        cell.iconeImageView.image = image
                        for x in cell.iconeImageView.constraints {
                            if x.identifier == "iconeImageViewHeight" {
                                x.constant = 24
                            }
                        }
                    }
                    else {
                        cell.backgroundColor = UIColor.whiteColor()
                        couleurTexte = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.darkenByPercentage(0.2)
                        
                        let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                        labelPictoLigne.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
                        labelPictoLigne.textAlignment = .Center
                        labelPictoLigne.textColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.darkenByPercentage(0.2)
                        labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                        labelPictoLigne.layer.borderColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.darkenByPercentage(0.2).CGColor
                        labelPictoLigne.layer.borderWidth = 1
                        
                        let image = labelToImage(labelPictoLigne)
                        cell.iconeImageView.image = image
                        for x in cell.iconeImageView.constraints {
                            if x.identifier == "iconeImageViewHeight" {
                                x.constant = 24
                            }
                        }
                        
                    }
                }
                else {
                    cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 24, height: 24))
                }
            }
            
            
            
            // Direction Label
            let attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
            attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["to"].stringValue))
            cell.directionLabel.attributedText = attributedString
		}
		else {
			let icone = FAKIonIcons.androidWalkIconWithSize(42)
            
            icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.backgroundColor = AppValues.primaryColor
            couleurTexte = AppValues.textColor
			
            cell.departLabel.text = ""
            cell.heureDepartLabel.text = ""
            cell.arriveeLabel.text = ""
            cell.heureArriveeLabel.text = ""
            
			cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 42, height: 42))
			cell.ligneLabel.text = "Marche".localized()
			cell.directionLabel.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["walk"]["duration"].stringValue.characters.split(":").map(String.init)[1] + " minute(s)".localized()
			
		}
        
        cell.ligneLabel.textColor = couleurTexte
        cell.directionLabel.textColor = couleurTexte
        cell.departLabel.textColor = couleurTexte
        cell.heureDepartLabel.textColor = couleurTexte
        cell.arriveeLabel.textColor = couleurTexte
        cell.heureArriveeLabel.textColor = couleurTexte
        
        var icone2 = FAKIonIcons.logOutIconWithSize(21)
        icone2.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        var attributedString = NSMutableAttributedString(attributedString: icone2.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["station"]["name"].stringValue))
        cell.departLabel.attributedText = attributedString
        
        var timestamp = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["departureTimestamp"].intValue
        cell.heureDepartLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        timestamp = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["arrival"]["arrivalTimestamp"].intValue
        cell.heureArriveeLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        icone2 = FAKIonIcons.logInIconWithSize(21)
        icone2.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        attributedString = NSMutableAttributedString(attributedString: icone2.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue))
        cell.arriveeLabel.attributedText = attributedString
		
		return cell
	}
	
	func toggleFavorite(sender: AnyObject!) {
		if AppValues.favorisItineraires.isEmpty {
			AppValues.favorisItineraires = [[ItineraireEnCours.itineraire.depart!, ItineraireEnCours.itineraire.arrivee!]]
		}
		else {
			if self.favoris {
				AppValues.favorisItineraires = AppValues.favorisItineraires.filter({ (arretA) -> Bool in
					if arretA[0].nomComplet == ItineraireEnCours.itineraire.depart?.nomComplet && arretA[1].nomComplet == ItineraireEnCours.itineraire.arrivee?.nomComplet {
						return false
					}
					return true
				})
			}
			else {
				AppValues.favorisItineraires.append([ItineraireEnCours.itineraire.depart!, ItineraireEnCours.itineraire.arrivee!])
			}
		}
		
		self.favoris = !self.favoris
		
		let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.favorisItineraires)
		defaults.setObject(encodedData, forKey: "itinerairesFavoris")
		
		var listeItems: [UIBarButtonItem] = []
		var favoris = false
		for x in AppValues.favorisItineraires {
			if x[0].nomComplet == ItineraireEnCours.itineraire.depart?.nomComplet && x[1].nomComplet == ItineraireEnCours.itineraire.arrivee?.nomComplet {
				favoris = true
				break
			}
		}
		if favoris {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action:#selector(VueItineraireTableViewController.toggleFavorite(_:))))
		}
		else {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(VueItineraireTableViewController.toggleFavorite(_:))))
		}
		self.navigationItem.rightBarButtonItems = listeItems
        let navController = self.splitViewController?.viewControllers[0] as! UINavigationController
        if (navController.viewControllers[0].isKindOfClass(ItineraireTableViewController)) {
            let itineraireTableViewController = navController.viewControllers[0] as! ItineraireTableViewController
            itineraireTableViewController.tableView.reloadData()
        }
	}
	
    func scheduleNotification(time: NSDate, before: Int = 5, ligne: String, direction: String, arretDescente: String) {
        let time2 = time - before.minutes
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time2)
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let date = cal.dateBySettingHour(now.hour, minute: now.minute, second: now.second, ofDate: time, options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate = date
        
        var texte =  "Le tpg de la ligne ".localized()
        texte += ligne
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
		let time = NSDate(timeIntervalSince1970: Double(ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["departureTimestamp"].intValue)).timeIntervalSinceDate(NSDate())
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
					self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 0, ligne: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1], direction: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["to"].stringValue, arretDescente: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue)
				})
				if time > 60 * 5 {
					alertView.addButton("5 min avant le départ".localized(), action: { () -> Void in
						self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 5, ligne: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1], direction: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["to"].stringValue, arretDescente: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue)
					})
				}
				if time > 60 * 10 {
					alertView.addButton("10 min avant le départ".localized(), action: { () -> Void in
						self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 10, ligne: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1], direction: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["to"].stringValue, arretDescente: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue)
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
							self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: Int(txt.text!)!, ligne: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1], direction: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue, arretDescente: ItineraireEnCours.json["connections"][self.compteur]["sections"][indexPath.row]["journey"]["to"].stringValue)
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
		return true
	}
}
