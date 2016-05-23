//
//  CreditsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 29/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework
import SafariServices

class CreditsTableViewController: UITableViewController {

    let listeCredits = [
        ["Open data des Transports Publics Genevois".localized(), "Données fournis par la société des Transports Publics Genevois".localized(), "http://www.tpg.ch/web/open-data/"],
        ["Open data de Transport API".localized(), "Données fournis par Opendata.ch".localized(), "https://transport.opendata.ch"],
        ["SwiftyJSON", "Projet maintenu sur GitHub par SwiftyJSON - Projet en licence MIT".localized(), "https://github.com/SwiftyJSON/SwiftyJSON.git"],
        ["Chameleon", "Projet maintenu sur GitHub par ViccAlexander - Projet en licence MIT".localized(), "https://github.com/ViccAlexander/Chameleon.git"],
        ["FontAwesomeKit", "Projet maintenu sur GitHub par PrideChung - Projet en licence MIT".localized(), "https://github.com/benguild/BGTableViewRowActionWithImage.git"],
        ["SCLAlertView-Swift", "Projet maintenu sur GitHub par vikmeup - Projet en licence MIT".localized(), "https://github.com/Pevika/SCLAlertView-Swift.git"],
        ["FSCalendar", "Projet maintenu sur GitHub par WenchaoIOS - Projet en licence MIT".localized(), "https://github.com/WenchaoIOS/FSCalendar.git"],
        ["DGRunkeeperSwitch", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized(), "https://github.com/gontovnik/DGRunkeeperSwitch.git"],
		["PermissionScope", "Projet maintenu sur GitHub par nickoneill - Projet en licence MIT".localized(), "https://github.com/nickoneill/PermissionScope.git"],
		["DGElasticPullToRefresh", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized(), "https://github.com/gontovnik/DGElasticPullToRefresh.git"],
		["MRProgress", "Projet maintenu sur GitHub par mrackwitz - Projet en licence MIT".localized(), "https://github.com/mrackwitz/MRProgress.git"],
		["INTULocationManager", "Projet maintenu sur GitHub par intuit - Projet en licence MIT".localized(), "https://github.com/intuit/LocationManager.git"],
		["SwiftInAppPurchase", "Projet maintenu sur GitHub par rpzzzzzz - Projet en licence MIT".localized(), "https://github.com/rpzzzzzz/SwiftInAppPurchase.git"],
		["Localize-Swift", "Projet maintenu sur GitHub par marmelroy - Projet en licence MIT".localized(), "https://github.com/marmelroy/Localize-Swift.git"],
		["Onboard", "Projet maintenu sur GitHub par mamaral - Projet en licence MIT".localized(), "https://github.com/mamaral/Onboard.git"],
		["Alamofire", "Projet maintenu sur GitHub par Alamofire - Projet en licence MIT".localized(), "https://github.com/Alamofire/Alamofire.git"],
		["EFCircularSlider", "Projet maintenu sur GitHub par eliotfowler et modifié par RemyDCF - Projet en licence MIT".localized(), "https://github.com/RemyDCF/EFCircularSlider.git"],
		["SwiftDate", "Projet maintenu sur GitHub par malcommac - Projet en licence MIT".localized(), "https://github.com/malcommac/SwiftDate"],
		["Log", "Projet maintenu sur GitHub par delba - Projet en licence MIT".localized(), "https://github.com/delba/Log.git"],
		["NVActivityIndicatorView", "Projet maintenu sur GitHub par ninjaprox - Projet en licence MIT".localized(), "https://github.com/ninjaprox/NVActivityIndicatorView.git"],
		["AsyncSwift", "Projet maintenu sur GitHub par duemunk - Projet en licence MIT".localized(), "https://github.com/duemunk/Async.git"],
		["AKPickerView-Swift", "Projet maintenu sur GitHub par Akkyie - Projet en licence MIT".localized(), "https://github.com/Akkyie/AKPickerView-Swift.git"],
		["SwiftTweaks", "Projet maintenu sur GitHub par Khan Academy - Projet en licence MIT".localized(), "https://github.com/Khan/SwiftTweaks.git"],
		["Fabric - Crashlytics", "Projet maintenu sur GitHub par Twitter - Projet en licence MIT".localized(), "https://fabric.io"]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()     
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        actualiserTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeCredits.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("creditsCell", forIndexPath: indexPath)

        cell.textLabel?.text = listeCredits[indexPath.row][0]
        cell.detailTextLabel?.text = listeCredits[indexPath.row][1]
        cell.textLabel?.textColor = AppValues.textColor
        cell.detailTextLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor
        
        let view = UIView()
        view.backgroundColor = AppValues.secondaryColor
        cell.selectedBackgroundView = view
        
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if #available(iOS 9.0, *) {
            let safariViewController = SFSafariViewController(URL: NSURL(string: listeCredits[tableView.indexPathForSelectedRow!.row][2])!, entersReaderIfAvailable: true)
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                safariViewController.view.tintColor = AppValues.primaryColor
            }
            else {
                safariViewController.view.tintColor = AppValues.textColor
            }
            presentViewController(safariViewController, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("showURL", sender: self)
        }
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showURL" {
			let destinationViewController: WebViewController = (segue.destinationViewController) as! WebViewController
			destinationViewController.url = listeCredits[tableView.indexPathForSelectedRow!.row][2]
		}
	}
}
