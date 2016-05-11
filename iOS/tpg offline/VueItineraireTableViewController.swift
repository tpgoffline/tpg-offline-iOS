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
	let defaults = NSUserDefaults.standardUserDefaults()
	var favoris = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		return ItineraireEnCours.itineraireResultat[compteur].correspondances.count
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
		
		if ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].categorie != .Marche {
			
            cell.ligneLabel.text = "Ligne " + ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne
            
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                
                if ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].isTpg {
                    cell.backgroundColor = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]
                    couleurTexte = AppValues.listeColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!
                    
                    let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                    labelPictoLigne.text = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne
                    labelPictoLigne.textAlignment = .Center
                    labelPictoLigne.textColor = couleurTexte
                    labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                    labelPictoLigne.layer.borderColor = couleurTexte.CGColor
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
                    cell.iconeImageView.image = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].getImageofType(42, color: UIColor.whiteColor())
                    for x in cell.iconeImageView.constraints {
                        if x.identifier == "iconeImageViewHeight" {
                            x.constant = 42
                        }
                    }
                }
                let attributedString = NSMutableAttributedString(attributedString: ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].getAttributedStringofType(24, color: UIColor.whiteColor()))
                attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].direction))
                cell.directionLabel.attributedText = attributedString
            }
            else {
                couleurTexte = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                cell.backgroundColor = AppValues.primaryColor
                
                if ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].isTpg {
                    if ContrastColorOf(AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!, returnFlat: true) == FlatWhite() {
                        cell.backgroundColor = UIColor.whiteColor()
                        couleurTexte = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!
                        let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                        labelPictoLigne.text = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne
                        labelPictoLigne.textAlignment = .Center
                        labelPictoLigne.textColor = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!
                        labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                        labelPictoLigne.layer.borderColor = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!.CGColor
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
                        couleurTexte = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!.darkenByPercentage(0.2)
                        
                        let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                        labelPictoLigne.text = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne
                        labelPictoLigne.textAlignment = .Center
                        labelPictoLigne.textColor = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!.darkenByPercentage(0.2)
                        labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                        labelPictoLigne.layer.borderColor = AppValues.listeBackgroundColor[ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].ligne]!.darkenByPercentage(0.2).CGColor
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
                    cell.iconeImageView.image = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].getImageofType(42, color: couleurTexte)
                }
                let attributedString = NSMutableAttributedString(attributedString: ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].getAttributedStringofType(24, color: couleurTexte))
                attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].direction))
                cell.directionLabel.attributedText = attributedString
            }
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
			cell.directionLabel.text = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].direction
			
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
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].de))
        cell.departLabel.attributedText = attributedString
        
        var timestamp = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].timestampDepart
        cell.heureDepartLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        timestamp = ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].timestampArrivee
        cell.heureArriveeLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        icone2 = FAKIonIcons.logInIconWithSize(21)
        icone2.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        attributedString = NSMutableAttributedString(attributedString: icone2.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.itineraireResultat[compteur].correspondances[indexPath.row].a))
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
		let time = NSDate(timeIntervalSince1970: Double(ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].timestampDepart)).timeIntervalSinceDate(NSDate())
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
					self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 0, ligne: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].ligne, direction: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].direction, arretDescente: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].a)
				})
				if time > 60 * 5 {
					alertView.addButton("5 min avant le départ".localized(), action: { () -> Void in
						self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 5, ligne: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].ligne, direction: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].direction, arretDescente: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].a)
					})
				}
				if time > 60 * 10 {
					alertView.addButton("10 min avant le départ".localized(), action: { () -> Void in
						self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: 10, ligne: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].ligne, direction: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].direction, arretDescente: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].a)
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
							self.scheduleNotification(NSDate(timeIntervalSinceNow: time), before: Int(txt.text!)!, ligne: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].ligne, direction: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].direction, arretDescente: ItineraireEnCours.itineraireResultat[self.compteur].correspondances[indexPath.row].a)
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
