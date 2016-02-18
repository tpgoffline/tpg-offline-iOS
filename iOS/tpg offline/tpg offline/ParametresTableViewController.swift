//
//  ParametresTableViewController.swift
//  tpg offline
//
//  Created by Alice on 20/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit

class ParametresTableViewController: UITableViewController {

    let listeRows = [
        [FAKFontAwesome.barsIconWithSize(20), "Choix du menu par défault", "showChoixDuMenuParDefault"],
        [FAKFontAwesome.locationArrowIconWithSize(20), "Localisation", "showLocationMenu"],
        [FAKFontAwesome.infoCircleIconWithSize(20), "Crédits", "showCredits"],
        [FAKFontAwesome.paintBrushIconWithSize(20), "Thèmes", "showThemesMenu"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        tableView.backgroundColor = AppValues.primaryColor
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
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
        performSegueWithIdentifier(listeRows[indexPath.row][2] as! String, sender: self)
    }
}
