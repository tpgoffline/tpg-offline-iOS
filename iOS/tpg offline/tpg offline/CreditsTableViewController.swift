//
//  CreditsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 29/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework

class CreditsTableViewController: UITableViewController {

    let listeCredits = [
        ["Open data des Transports Publics Genevois".localized(), "Données fournis par la société des Transports Publics Genevois".localized(), "http://www.tpg.ch/web/open-data/"],
        ["Open data de Transport API".localized(), "Données fournis par Opendata.ch".localized(), "https://transport.opendata.ch"],
        ["SwiftyJSON", "Projet maintenu sur GitHub par SwiftyJSON - Projet en licence MIT".localized(), "https://github.com/SwiftyJSON/SwiftyJSON.git"],
        ["Chamelon", "Projet maintenu sur GitHub par ViccAlexander - Projet en licence MIT".localized(), "https://github.com/ViccAlexander/Chameleon.git"],
        ["FontAwesomeKit", "Projet maintenu sur GitHub par PrideChung - Projet en licence MIT".localized(), "https://github.com/benguild/BGTableViewRowActionWithImage.git"],
        ["BGTableViewRowActionWithImage", "Projet maintenu sur GitHub par benguild - Projet en licence MIT".localized(), "https://github.com/benguild/BGTableViewRowActionWithImage.git"],
        ["SCLAlertView-Swift", "Projet maintenu sur GitHub par vikmeup - Projet en licence MIT".localized(), "https://github.com/Pevika/SCLAlertView-Swift.git"],
        ["FSCalendar", "Projet maintenu sur GitHub par WenchaoIOS - Projet en licence MIT".localized(), "https://github.com/WenchaoIOS/FSCalendar.git"],
        ["DGRunkeeperSwitch", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized(), "https://github.com/gontovnik/DGRunkeeperSwitch.git"],
		["EFCircularSlider", "Projet maintenu sur GitHub par eliotfowler et modifié par RemyDCF - Projet en licence MIT".localized(), "https://github.com/RemyDCF/EFCircularSlider.git"],
		["PermissionScope", "Projet maintenu sur GitHub par nickoneill - Projet en licence MIT".localized(), "https://github.com/nickoneill/PermissionScope.git"],
		["DGElasticPullToRefresh", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized(), "https://github.com/gontovnik/DGElasticPullToRefresh.git"],
		["MRProgress", "Projet maintenu sur GitHub par mrackwitz - Projet en licence MIT".localized(), "https://github.com/mrackwitz/MRProgress.git"],
		["INTULocationManager", "Projet maintenu sur GitHub par intuit - Projet en licence MIT".localized(), "https://github.com/intuit/LocationManager.git"],
		["SwiftyStoreKit", "Projet maintenu sur GitHub par bizz84 - Projet en licence MIT".localized(), "https://github.com/bizz84/SwiftyStoreKit.git"],
		["Localize-Swift", "Projet maintenu sur GitHub par marmelroy - Projet en licence MIT".localized(), "https://github.com/marmelroy/Localize-Swift.git"],
		["Onboard", "Projet maintenu sur GitHub par mamaral - Projet en licence MIT".localized(), "https://github.com/mamaral/Onboard.git"],
		["SAHistoryNavigationViewController", "Projet maintenu sur GitHub par szk-atmosphere - Projet en licence MIT".localized(), "https://github.com/szk-atmosphere/SAHistoryNavigationViewController.git"],
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = AppValues.primaryColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
		navigationController?.setHistoryBackgroundColor(AppValues.secondaryColor.darkenByPercentage(0.3))
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
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
		UIApplication.sharedApplication().openURL(NSURL(string: listeCredits[indexPath.row][2])!)
	}
}
