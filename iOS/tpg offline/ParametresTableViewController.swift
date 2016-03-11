//
//  ParametresTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 20/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import Onboard
import Google
import Alamofire
import MRProgress
import SCLAlertView

class ParametresTableViewController: UITableViewController {
	
	var listeRows = [
		[FAKFontAwesome.barsIconWithSize(20), "Choix du menu par défaut".localized(), "showChoixDuMenuParDefault"],
		[FAKFontAwesome.locationArrowIconWithSize(20), "Localisation".localized(), "showLocationMenu"],
		[FAKFontAwesome.infoCircleIconWithSize(20), "Crédits".localized(), "showCredits"],
		[FAKFontAwesome.githubIconWithSize(20), "Page GitHub du projet".localized(), "showGitHub"],
		[FAKFontAwesome.graduationCapIconWithSize(20), "Revoir le tutoriel".localized(), "showTutoriel"]
	]
	
	let listeRowPremium = [
		[FAKFontAwesome.paintBrushIconWithSize(20), "Thèmes".localized(), "showThemesMenu"],
		[FAKFontAwesome.refreshIconWithSize(20), "Actualiser les départs".localized(), "actualiserDeparts"]
	]
	
	let listeRowNonPremium = [
		[FAKFontAwesome.starIconWithSize(20), "Premium".localized(), "showPremium"]
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		actualiserTheme()
		if (AppValues.premium == true) {
			listeRows += listeRowPremium
		}
		else {
			listeRows += listeRowNonPremium
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		actualiserTheme()
		
		if !(NSProcessInfo.processInfo().arguments.contains("-withoutAnalytics")) {
			let tracker = GAI.sharedInstance().defaultTracker
			tracker.set(kGAIScreenName, value: "ParamètresTableViewController")
			tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]!)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return listeRows.count
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("parametresCell", forIndexPath: indexPath)
		
		cell.textLabel!.text = (listeRows[indexPath.row][1] as! String)
		let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
		iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
		let icone = listeRows[indexPath.row][0] as! FAKFontAwesome
		icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		cell.imageView?.image = icone.imageWithSize(CGSize(width: 20, height: 20))
		cell.backgroundColor = AppValues.primaryColor
		cell.textLabel?.textColor = AppValues.textColor
		
		let view = UIView()
		view.backgroundColor = AppValues.secondaryColor
		cell.selectedBackgroundView = view
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if listeRows[indexPath.row][2] as! String == "showTutoriel" {
			afficherTutoriel()
		}
        else if listeRows[indexPath.row][2] as! String == "actualiserDeparts" {
            actualiserDeparts()
        }
		else {
			performSegueWithIdentifier(listeRows[indexPath.row][2] as! String, sender: self)
		}
	}
	
    func actualiserDeparts() {
        CATransaction.begin()
        
        let progressBar = MRProgressOverlayView.showOverlayAddedTo(self.view.window, title: "Chargement", mode: .DeterminateCircular, animated: true)
        if ContrastColorOf(AppValues.secondaryColor, returnFlat: true) == FlatWhite() {
            progressBar.tintColor = AppValues.secondaryColor
            progressBar.titleLabel!.textColor = AppValues.secondaryColor
        }
        else {
            progressBar.tintColor = AppValues.textColor
            progressBar.titleLabel!.textColor = AppValues.textColor
        }
        
        CATransaction.setCompletionBlock({
            Alamofire.request(.GET, "https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/Departs/listeDeparts.json").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (index, subJson) in json {
                            progressBar.setProgress(Float((Int(index)! * 100) / json.count) / 100, animated: true)
                            Alamofire.request(.GET, "https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/Departs/" + subJson.stringValue).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    if let value2 = response.result.value {
                                        let json2 = JSON(value2)
                                        let file = NSBundle.mainBundle().pathForResource(subJson.stringValue, ofType: "", inDirectory: "Departs")
                                        do {
                                            try json2.rawString()!.writeToFile(file!, atomically: false, encoding: NSUTF8StringEncoding)
                                            print(json2)
                                        }
                                        catch {}
                                    }
                                case .Failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                    progressBar.dismiss(true)
                case .Failure(let error):
                    print(error)
                    progressBar.dismiss(true)
                }
            }
        })
        
        CATransaction.commit()
    }
    
	func afficherTutoriel() {
		let rect = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		
		CGContextSetFillColorWithColor(context, AppValues.primaryColor.CGColor)
		
		CGContextFillRect(context, rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		let page1 = OnboardingContentViewController (title: "Bienvenue dans tpg offline".localized(), body: "tpg offline est une application qui facilite vos déplacements avec les transports publics genevois, même sans réseau.".localized(), image: nil, buttonText: "Continuer".localized(), actionBlock: nil)
		
		let iconeI = FAKIonIcons.iosClockIconWithSize(50)
		iconeI.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page2 = OnboardingContentViewController (title: "Départs".localized(), body: "Le menu Départs vous informe des prochains départs pour un arrêt.".localized(), image: iconeI.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		var iconeF = FAKFontAwesome.globeIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page3 = OnboardingContentViewController (title: "Mode offline".localized(), body: "Le Mode offline vous permet de connaitre les horaires à un arrêt même si vous n’avez pas de réseau.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.warningIconWithSize(50)
		
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page4 = OnboardingContentViewController (title: "Avertissement".localized(), body: "Sans réseau, tpg offline ne permet pas d’avoir des horaires garantis ni de connaitre les possibles perturbations du réseau. \rtpg offline ne peut aucunement être tenu pour responsable en cas de retard, d’avance, ni de connection manquée.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "J'ai compris, continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.mapSignsIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page5 = OnboardingContentViewController (title: "Itinéraires".localized(), body: "l’application propose un menu Itinéraires. Vous pouvez vous déplacer très facilement grâce à cette fonction.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.mapIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page6 = OnboardingContentViewController (title: "Plans".localized(), body: "Tous les plans des tpg sont disponibles dans le menu Plans.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.warningIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page7 = OnboardingContentViewController (title: "Incidents".localized(), body: "Soyez avertis en cas de perturbations sur le réseau tpg grâce au menu Incidents.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.bellOIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page8 = OnboardingContentViewController (title: "Rappels".localized(), body: "Dans les menus Départs et Itinéraires, faite glisser un des horaires proposés vers la gauche pour être notifié(e) d’un départ et éviter de rater votre transport ou votre connection.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.githubIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page9 = OnboardingContentViewController (title: "Open Source", body: "tpg offline est Open Source. Vous pouvez donc modifier et améliorer l’application si vous le souhaitez.\rSi vous avez des idées ou que vous trouvez un bug, n'hésitez pas à consulter notre projet sur GitHub. (https://github.com/RemyDCF/tpg-offline)".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.ellipsisHIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		let page10 = OnboardingContentViewController (title: "Et beaucoup d'autres choses".localized(), body: "D'autres surprises vous attendent dans l'application. Alors, partez à l'aventure et bon voyage !".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Terminer".localized(), actionBlock: { (onboardingvc) in
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		
		page1.movesToNextViewController = true
		page2.movesToNextViewController = true
		page3.movesToNextViewController = true
		page4.movesToNextViewController = true
		page5.movesToNextViewController = true
		page6.movesToNextViewController = true
		page7.movesToNextViewController = true
		page8.movesToNextViewController = true
		page9.movesToNextViewController = true
		
		let onboardingVC = OnboardingViewController(backgroundImage: image, contents: [page1, page2, page3, page4, page5, page6, page7, page8, page9, page10])
		onboardingVC.titleTextColor = AppValues.textColor
		onboardingVC.bodyTextColor = AppValues.textColor
		onboardingVC.buttonTextColor = AppValues.textColor
		onboardingVC.pageControl.pageIndicatorTintColor = AppValues.secondaryColor
		onboardingVC.pageControl.currentPageIndicatorTintColor = AppValues.textColor
		onboardingVC.skipButton.setTitleColor(AppValues.textColor, forState: .Normal)
		onboardingVC.bodyFontSize = 18
		onboardingVC.shouldMaskBackground = false
		onboardingVC.shouldFadeTransitions = true
		onboardingVC.allowSkipping = true
		onboardingVC.skipButton.setTitle("Passer".localized(), forState: .Normal)
		onboardingVC.skipHandler = {
			self.dismissViewControllerAnimated(true, completion: nil)
		}
		presentViewController(onboardingVC, animated: true, completion: nil)
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showGitHub" {
			let destinationViewController: WebViewController = (segue.destinationViewController) as! WebViewController
			destinationViewController.url = "https://github.com/RemyDCF/tpg-offline"
		}
	}
}
