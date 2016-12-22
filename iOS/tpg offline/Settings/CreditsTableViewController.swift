//
//  CreditsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 29/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Chameleon
import SafariServices

class CreditsTableViewController: UITableViewController {

    let creditsList = [
        ["Open data des Transports Publics Genevois".localized, "Données fournis par la société des Transports Publics Genevois".localized, "http://www.tpg.ch/web/open-data/"],
        ["Open data de Transport API".localized, "Données fournis par Opendata.ch".localized, "https://transport.opendata.ch"],
        ["SwiftyJSON", "Projet maintenu sur GitHub par SwiftyJSON - Projet en licence MIT".localized, "https://github.com/SwiftyJSON/SwiftyJSON.git"],
        ["Chameleon", "Projet maintenu sur GitHub par ViccAlexander - Projet en licence MIT".localized, "https://github.com/ViccAlexander/Chameleon.git"],
        ["FontAwesomeKit", "Projet maintenu sur GitHub par PrideChung - Projet en licence MIT".localized, "https://github.com/benguild/BGTableViewRowActionWithImage.git"],
        ["SCLAlertView-Swift", "Projet maintenu sur GitHub par vikmeup - Projet en licence MIT".localized, "https://github.com/Pevika/SCLAlertView-Swift.git"],
        ["FSCalendar", "Projet maintenu sur GitHub par WenchaoIOS - Projet en licence MIT".localized, "https://github.com/WenchaoIOS/FSCalendar.git"],
        ["DGRunkeeperSwitch", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized, "https://github.com/gontovnik/DGRunkeeperSwitch.git"],
		["PermissionScope", "Projet maintenu sur GitHub par nickoneill - Projet en licence MIT".localized, "https://github.com/nickoneill/PermissionScope.git"],
		["DGElasticPullToRefresh", "Projet maintenu sur GitHub par gontovnik - Projet en licence MIT".localized, "https://github.com/gontovnik/DGElasticPullToRefresh.git"],
		["VHUD", "Projet maintenu sur GitHub par xxxAIRINxxx - Projet en licence MIT".localized, "https://github.com/xxxAIRINxxx/VHUD"],
		["Onboard", "Projet maintenu sur GitHub par mamaral - Projet en licence MIT".localized, "https://github.com/mamaral/Onboard.git"],
		["Alamofire", "Projet maintenu sur GitHub par Alamofire - Projet en licence MIT".localized, "https://github.com/Alamofire/Alamofire.git"],
		["EFCircularSlider", "Projet maintenu sur GitHub par eliotfowler et modifié par RemyDCF - Projet en licence MIT".localized, "https://github.com/RemyDCF/EFCircularSlider.git"],
		["NVActivityIndicatorView", "Projet maintenu sur GitHub par ninjaprox - Projet en licence MIT".localized, "https://github.com/ninjaprox/NVActivityIndicatorView.git"],
		["AsyncSwift", "Projet maintenu sur GitHub par duemunk - Projet en licence MIT".localized, "https://github.com/duemunk/Async.git"],
		["AKPickerView-Swift", "Projet maintenu sur GitHub par Akkyie - Projet en licence MIT".localized, "https://github.com/Akkyie/AKPickerView-Swift.git"],
		["Fabric - Crashlytics", "Projet maintenu sur GitHub par Twitter - Projet en licence MIT".localized, "https://fabric.io"]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "creditsCell", for: indexPath)

        cell.textLabel?.text = creditsList[indexPath.row][0]
        cell.detailTextLabel?.text = creditsList[indexPath.row][1]
        cell.textLabel?.textColor = AppValues.textColor
        cell.detailTextLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor
        
        let view = UIView()
        view.backgroundColor = AppValues.primaryColor
        cell.selectedBackgroundView = view
        
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let safariViewController = SFSafariViewController(url: URL(string: creditsList[tableView.indexPathForSelectedRow!.row][2])!, entersReaderIfAvailable: true)
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                safariViewController.view.tintColor = AppValues.primaryColor
            }
            else {
                safariViewController.view.tintColor = AppValues.textColor
            }
            present(safariViewController, animated: true, completion: nil)
	}
}
