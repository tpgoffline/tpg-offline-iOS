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
        ["Open data des Transports Publics Genevois".localized(), "Données fournis par la société des Transports Publics Genevois".localized()],
        ["Open data de Transport API".localized(), "Données fournis par Opendata.ch".localized()],
        ["SwiftyJSON", "Projet maintenu sur GitHub par SwiftyJSON - Projet en licence MIT".localized()],
        ["Chamelon", "Projet maintenu sur GitHub par ViccAlexander - Projet en licence MIT".localized()],
        ["FontAwesomeKit", "Projet maintenu sur GitHub par PrideChung - Projet en licence MIT".localized()],
        ["BGTableViewRowActionWithImage", "Projet maintenu sur GitHub par benguild - Projet en licence MIT".localized()],
        ["SCLAlertView-Swift", "Projet maintenu sur GitHub par vikmeup - Projet en licence MIT".localized()],
        ["FSCalendar", "Projet maintenu sur GitHub par WenchaoIOS - Projet en licence MIT".localized()],
        ["DGRunkeeperSwitch", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized()],
		["EFCircularSlider", "Projet maintenu sur GitHub par eliotfowler et modifié par RemyDCF - Projet en licence MIT".localized()],
		["PermissionScope", "Projet maintenu sur GitHub par nickoneill - Projet en licence MIT".localized()]
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
}
