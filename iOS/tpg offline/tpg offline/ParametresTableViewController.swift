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

class ParametresTableViewController: UITableViewController {
	
	var listeRows = [
		[FAKFontAwesome.barsIconWithSize(20), "Choix du menu par défaut".localized(), "showChoixDuMenuParDefault"],
		[FAKFontAwesome.locationArrowIconWithSize(20), "Localisation".localized(), "showLocationMenu"],
		[FAKFontAwesome.infoCircleIconWithSize(20), "Crédits".localized(), "showCredits"],
		[FAKFontAwesome.githubIconWithSize(20), "Page GitHub du projet".localized(), "showGitHub"],
		[FAKFontAwesome.graduationCapIconWithSize(20), "Revoir le tutoriel".localized(), "showTutoriel"]
	]
	
	let listeRowPremium = [
		[FAKFontAwesome.paintBrushIconWithSize(20), "Thèmes".localized(), "showThemesMenu"]
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
		else {
			performSegueWithIdentifier(listeRows[indexPath.row][2] as! String, sender: self)
		}
	}
	
	func afficherTutoriel() {
		let rect = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		
		CGContextSetFillColorWithColor(context, UIColor.flatOrangeColor().CGColor)
		CGContextFillRect(context, rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		let page1 = OnboardingContentViewController (title: "Bienvenue dans tpg offline".localized(), body: "tpg offline est une application qui permet de faciliter vos voyages avec les transports publics genevois".localized(), image: nil, buttonText: "Continuer".localized(), actionBlock: nil)
		
		let iconeI = FAKIonIcons.iosClockIconWithSize(50)
		iconeI.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page2 = OnboardingContentViewController (title: "Départs".localized(), body: "Le menu Départs vous permet de voir quels sont les prochains bus pour un arrêt".localized(), image: iconeI.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		var iconeF = FAKFontAwesome.globeIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page3 = OnboardingContentViewController (title: "Mode offline".localized(), body: "Dans les départs, si vous n'avez pas de réseau, tpg offline vous permet de savoir quand appoximativement votre transport part.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.warningIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page4 = OnboardingContentViewController (title: "Avertissement".localized(), body: "En mode hors ligne, tpg offline ne vous permet pas d'avoir des horaires précis. tpg offline n'est en aucun cas responsable en cas de retard, d'avance, de perturbation des transports.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "J'ai compris, continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.mapSignsIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page5 = OnboardingContentViewController (title: "Itinéraires".localized(), body: "L'application propose un menu itinéraire. Vous pouvez vous déplacer avec une facilité incroyable grâce à cette fonction.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.mapIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page6 = OnboardingContentViewController (title: "Plan".localized(), body: "Tous les plans des tpg sont disponibles dans le menu plan".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.warningIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page7 = OnboardingContentViewController (title: "Incidents".localized(), body: "Soyez avertis en cas de perturbations sur le réseau tpg grâce au menu Incidents.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.bellOIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page8 = OnboardingContentViewController (title: "Rappels".localized(), body: "Dans les départs et itinéraires, en glissant votre doigt de gauche à droite, découvrez comment les rappels peuvent vous éviter de voir le bus partir sans vous...".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.githubIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page9 = OnboardingContentViewController (title: "Open Source", body: "tpg offline est open source. Tout le monde peut modifier et améliorer l'application. Si vous avez des idées ou que vous trouvez un bug, n'hésitez pas à consulter notre projet sur GitHub. (https://github.com/RemyDCF/tpg-offline)".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
		iconeF = FAKFontAwesome.ellipsisHIconWithSize(50)
		iconeF.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
		let page10 = OnboardingContentViewController (title: "Et beaucoup d'autre choses".localized(), body: "D'autres surprises vous attendent dans l'application. Alors, partez à l'aventure et bon voyage !".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Terminer".localized(), actionBlock: { (onboardingvc) in
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
		onboardingVC.bodyFontSize = 20
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
