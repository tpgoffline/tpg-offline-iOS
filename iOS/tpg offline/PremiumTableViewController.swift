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
import SwiftInAppPurchase
import SCLAlertView

class PremiumTableViewController: UITableViewController {
	
	var price = ""
	var productKey = "B17EDFEA961F4680B88A309704032DA7"
	let defaults = NSUserDefaults.standardUserDefaults()
    let iap = SwiftInAppPurchase.sharedInstance
	
	let arguments = [
		[FAKFontAwesome.globeIconWithSize(20), "Mode offline des départs".localized(), "Pas de réseau ? Pas de problème avec le mode offline, vous pouvez accéder aux horaires hors ligne. Attetion : Les horaires du mode offline ne peuvent pas prévoir les évantuels retards, avances, perturbation en cours sur le réseau tpg.".localized()],
		[FAKFontAwesome.paintBrushIconWithSize(20), "Thèmes".localized(), "Avec le premium, vous pouvez accéder à une multitude de thèmes pour personnaliser votre application.".localized()],
		[FAKFontAwesome.mapSignsIconWithSize(20), "Favoris des itinéraires".localized(), "Avec les favoris des itinéraires, vous pouvez en un seul appui voir les prochains itinéraires de un point à un autre.".localized()],
		[FAKFontAwesome.ellipsisHIconWithSize(20), "Fonctionnalités futures".localized(), "Un seul achat et vous aurez toutes les merveilles à venir. Pour toujours !".localized()]
	]
	
	let boutonsStoreKit = ["Acheter".localized(), "Restaurer les achats".localized()]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshTheme()
		
        iap.setProductionMode(false)
        var productIden = Set<String>()
        productIden.insert(productKey)
        
        self.iap.requestProducts(productIden) { (products, invalidIdentifiers, error) -> () in
            if error == nil {
                let product = products![0]
                let numberFormatter = NSNumberFormatter()
                numberFormatter.formatterBehavior = .Behavior10_4
                numberFormatter.numberStyle = .CurrencyStyle
                numberFormatter.locale = product.priceLocale
                let priceString = numberFormatter.stringFromNumber(product.price)
                self.price = priceString!
                self.tableView.reloadData()
            }
            else {
                AppValues.logger.error(error)
            }
        }
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		refreshTheme()
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
			let cell = tableView.dequeueReusableCellWithIdentifier("titrePremiumCell", forIndexPath: indexPath) as! PremiumTableViewCell
			
			let icone = FAKIonIcons.starIconWithSize(30)
			icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			let attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
			attributedString.appendAttributedString(NSAttributedString(string: " Premium"))
			cell.titleLabel.attributedText = attributedString
			cell.titleLabel.textColor = AppValues.textColor
			
			cell.backgroundColor = AppValues.primaryColor
			let selectedView = UIView()
			selectedView.backgroundColor = AppValues.primaryColor
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
			selectedView.backgroundColor = AppValues.primaryColor
			cell.selectedBackgroundView = selectedView
			
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("acheterPremiumCell", forIndexPath: indexPath) as! BuyPremiumTableViewCell
			
			cell.buyButton.setTitle(boutonsStoreKit[indexPath.row], forState: .Normal)
			cell.buyButton.backgroundColor = UIColor.flatGreenColor()
			
			if indexPath.row == 0 {
				cell.buyButton.addTarget(self, action: #selector(PremiumTableViewController.acheter(_:)), forControlEvents: .TouchUpInside)
				if price != "" {
					cell.buyButton.setTitle("\(boutonsStoreKit[indexPath.row]) (\(price))", forState: .Normal)
				}
			}
			else if indexPath.row == 1 {
				cell.buyButton.addTarget(self, action: #selector(PremiumTableViewController.restaurerAchat(_:)), forControlEvents: .TouchUpInside)
			}
			
			return cell
		}
	}
	
	func acheter(sender: AnyObject!) {
        self.iap.addPayment(productKey, userIdentifier: nil) { (result) -> () in
            
            switch result{
            case .Purchased(let productId,let transaction,let paymentQueue):
                paymentQueue.finishTransaction(transaction)
                AppValues.logger.info("Purchase Success: \(productId)")
                AppValues.premium = true
                self.defaults.setBool(true, forKey: "premium")
                let alerte = SCLAlertView()
                alerte.showSuccess("L'achat a réussi".localized(), subTitle: "Toutes les fonctions premium sont débloquées. Merci beaucoup ! Nous vous recommendons de télécharger les départs hors ligne dans les paramètres.".localized(), closeButtonTitle: "Fermer".localized(), duration: 30).setDismissBlock({
                    if ((self.navigationController?.viewControllers[0].isKindOfClass(SettingsTableViewController)) == true) {
                       (self.navigationController?.viewControllers[0] as! SettingsTableViewController).tableView.reloadData()
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
            case .Failed(let error):
                AppValues.logger.error("Purchase Failed: \(error)")
                let alerte = SCLAlertView()
                alerte.showError("Échec".localized(), subTitle: "L'achat n'a pas pu être finalisé. Merci de vérifier si les achats intégrés sont autorisés dans Réglages > Général > Restrictions.".localized(), closeButtonTitle: "Fermer".localized(), duration: 20)
                
            default:
                break
            }            
        }
	}
	
	func restaurerAchat(sender: AnyObject!) {
        
        self.iap.restoreTransaction(nil) { (result) -> () in
            switch result{
            case .Restored(let productId,let transaction,let paymentQueue) :
                paymentQueue.finishTransaction(transaction)
                AppValues.logger.info("Restore Success: \(productId)")
                AppValues.premium = true
                self.defaults.setBool(true, forKey: "premium")
                let alerte = SCLAlertView()
                alerte.showSuccess("La restauration à réussi".localized(), subTitle: "Toutes les fonctions premium sont débloquées. Merci beaucoup ! Nous vous recommendons de télécharger les départs hors ligne dans les paramètres.".localized(), closeButtonTitle: "Fermer".localized(), duration: 20).setDismissBlock({
                    if ((self.navigationController?.viewControllers[0].isKindOfClass(SettingsTableViewController)) == true) {
                        (self.navigationController?.viewControllers[0] as! SettingsTableViewController).tableView.reloadData()
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
            case .Failed(let error):
                AppValues.logger.error("Restore Failed: \(error)")
                let alerte = SCLAlertView()
                alerte.showError("Échec", subTitle: "La restauration n'a pas pu être finalisé. Merci de vérifier si les achats intégrés sont autorisés dans Réglages > Général > Restrictions.".localized(), closeButtonTitle: "Fermer".localized(), duration: 20)
                
            default:
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
