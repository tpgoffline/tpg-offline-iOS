//
//  PremiumTableViewController.swift
//  tpg offline
//
//  Created by remy on 24/02/16.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import FontAwesomeKit
import ChameleonFramework
import SwiftyStoreKit
import SCLAlertView
import Google

class PremiumTableViewController: UITableViewController {
	
	var price = ""
	var productKey = "B17EDFEA961F4680B88A309704032DA7"
	let defaults = NSUserDefaults.standardUserDefaults()
	
	let arguments = [
		[FAKFontAwesome.globeIconWithSize(20), "Mode offline des départs".localized(), "Pas de réseau ? Pas de problème avec le mode offline, vous pouvez accéder aux horaires hors ligne. Attetion : Les horaires du mode offline ne peuvent pas prévoir les évantuels retards, avances, perturbation en cours sur le réseau tpg.".localized()],
		[FAKFontAwesome.paintBrushIconWithSize(20), "Thèmes".localized(), "Avec le premium, vous pouvez accéder à une multitude de thèmes pour personnaliser votre application.".localized()],
		[FAKFontAwesome.mapSignsIconWithSize(20), "Favoris des itinéraires".localized(), "Avec les favoris des itinéraires, vous pouvez en un seul appui voir les prochains itinéraires de un point à un autre.".localized()],
		[FAKFontAwesome.ellipsisHIconWithSize(20), "Fonctionnalités futures".localized(), "Un seul achat et vous aurez toutes les merveilles à venir. Pour toujours !".localized()]
	]
	
	let boutonsStoreKit = ["Acheter".localized(), "Restaurer les achats".localized()]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		actualiserTheme()
		
		SwiftyStoreKit.retrieveProductInfo(productKey) { result in
			switch result {
			case .Success(let product):
				let numberFormatter = NSNumberFormatter()
				numberFormatter.formatterBehavior = .Behavior10_4
				numberFormatter.numberStyle = .CurrencyStyle
				numberFormatter.locale = product.priceLocale
				let priceString = numberFormatter.stringFromNumber(product.price)
				self.price = priceString!
				self.tableView.reloadData()
				break
			case .Error(let error):
				print("Error: \(error)")
				break
			}
		}
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		actualiserTheme()
		
		if !(NSProcessInfo.processInfo().arguments.contains("-withoutAnalytics")) {
			let tracker = GAI.sharedInstance().defaultTracker
			tracker.set(kGAIScreenName, value: "PremiumTableViewController")
			tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]!)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return arguments.count
		case 2:
			return boutonsStoreKit.count
		default:
			return 0
		}
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("titrePremiumCell", forIndexPath: indexPath) as! TitrePremiumTableViewCell
			
			let icone = FAKIonIcons.starIconWithSize(30)
			icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			let attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
			attributedString.appendAttributedString(NSAttributedString(string: " Premium"))
			cell.titreLabel.attributedText = attributedString
			cell.titreLabel.textColor = AppValues.textColor
			
			cell.backgroundColor = AppValues.primaryColor
			let selectedView = UIView()
			selectedView.backgroundColor = AppValues.secondaryColor
			cell.selectedBackgroundView = selectedView
			
			return cell
		}
		else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("premiumCell", forIndexPath: indexPath)
			
			let icone = arguments[indexPath.row][0] as! FAKFontAwesome
			icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			cell.imageView?.image = icone.imageWithSize(CGSize(width: 20, height: 20))
			
			cell.textLabel!.text = arguments[indexPath.row][1] as? String
			cell.textLabel?.textColor = AppValues.textColor
			
			cell.detailTextLabel?.text = arguments[indexPath.row][2] as? String
			cell.detailTextLabel?.textColor = AppValues.textColor
			
			cell.backgroundColor = AppValues.primaryColor
			let selectedView = UIView()
			selectedView.backgroundColor = AppValues.secondaryColor
			cell.selectedBackgroundView = selectedView
			
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("acheterPremiumCell", forIndexPath: indexPath) as! AcheterPremiumTableViewCell
			
			cell.boutonAcheter.setTitle(boutonsStoreKit[indexPath.row], forState: .Normal)
			cell.boutonAcheter.backgroundColor = UIColor.flatGreenColor()
			
			if indexPath.row == 0 {
				cell.boutonAcheter.addTarget(self, action: "acheter:", forControlEvents: .TouchUpInside)
				if price != "" {
					cell.boutonAcheter.setTitle("\(boutonsStoreKit[indexPath.row]) (\(price))", forState: .Normal)
				}
			}
			else if indexPath.row == 1 {
				cell.boutonAcheter.addTarget(self, action: "restaurerAchat:", forControlEvents: .TouchUpInside)
			}
			
			return cell
		}
	}
	
	func acheter(sender: AnyObject!) {
		SwiftyStoreKit.purchaseProduct(productKey) { result in
			switch result {
			case .Success(let productId):
				print("Purchase Success: \(productId)")
				AppValues.premium = true
				self.defaults.setBool(true, forKey: "premium")
				let alerte = SCLAlertView()
				alerte.showSuccess("L'achat a réussi".localized(), subTitle: "Toutes les fonctions premium sont débloquées. Merci beaucoup ! Nous vous recommendons de télécharger les départs hors ligne dans les paramètres.".localized(), closeButtonTitle: "Fermer".localized(), duration: 30).setDismissBlock({
					self.navigationController?.popViewControllerAnimated(true)
				})
				break
			case .Error(let error):
				print("Purchase Failed: \(error)")
				let alerte = SCLAlertView()
				alerte.showError("Échec".localized(), subTitle: "L'achat n'a pas pu être finalisé. Merci de vérifier si les achats intégrés sont autorisés dans Réglages > Général > Restrictions.".localized(), closeButtonTitle: "Fermer".localized(), duration: 20)
				break
			}
		}
	}
	
	func restaurerAchat(sender: AnyObject!) {
		SwiftyStoreKit.restorePurchases() { result in
			switch result {
			case .Success(let productId):
				print("Restore Success: \(productId)")
				AppValues.premium = true
				self.defaults.setBool(true, forKey: "premium")
				let alerte = SCLAlertView()
				alerte.showSuccess("La restauration à réussi".localized(), subTitle: "Toutes les fonctions premium sont débloquées. Merci beaucoup ! Nous vous recommendons de télécharger les départs hors ligne dans les paramètres.".localized(), closeButtonTitle: "Fermer".localized(), duration: 20).setDismissBlock({
					self.navigationController?.popViewControllerAnimated(true)
				})
				break
			case .NothingToRestore:
				print("Nothing to Restore")
				let alerte = SCLAlertView()
				alerte.showWarning("Rien à restauré", subTitle: "Le mode premium n'a pas été acheté. Nous ne pouvons donc pas restaurer d'achat.".localized(), closeButtonTitle: "Fermer", duration: 20)
				break
			case .Error(let error):
				print("Restore Failed: \(error)")
				let alerte = SCLAlertView()
				alerte.showError("Échec", subTitle: "La restauration n'a pas pu être finalisé. Merci de vérifier si les achats intégrés sont autorisés dans Réglages > Général > Restrictions.".localized(), closeButtonTitle: "Fermer".localized(), duration: 20)
				break
			}
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 2 {
			return 44
		}
		else {
			return 100
		}
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
