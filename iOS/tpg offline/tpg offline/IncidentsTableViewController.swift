//
//  IncidentsTableViewController.swift
//  tpg offline
//
//  Created by Alice on 17/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import DGElasticPullToRefresh

class IncidentsTableViewController: UITableViewController {
    
    let tpgUrl = tpgURL()
    let defaults = NSUserDefaults.standardUserDefaults()
    var distrubtions: [Perturbations] = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    var erreur = false
    var aucunProbleme = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
		let loadingView = DGElasticPullToRefreshLoadingViewCircle()
		loadingView.tintColor = AppValues.textColor
		
		tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
			
			self!.refresh(loadingView)
			self?.tableView.dg_stopLoading()
			
			}, loadingView: loadingView)
		
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
        navigationController?.navigationBar.barTintColor = UIColor.flatOrangeColorDark()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if let dataArrets = tpgUrl.getDisruptions() {
            let json = JSON(data: dataArrets)
            if json["disruptions"].count != 0 {
                for x in 0...json["disruptions"].count - 1 {
                    if json["disruptions"][x]["lineCode"].string?.characters.count != 1 && json["disruptions"][x]["lineCode"].string?.characters.first == "T" {
                        
                    }
                    else {
                        distrubtions.append(Perturbations(lineCode: json["disruptions"][x]["lineCode"].string!, title: json["disruptions"][x]["nature"].string!, subTitle: json["disruptions"][x]["consequence"].string!))
                    }
                }
            }
            else {
                aucunProbleme = true
            }
        }
        else {
            erreur = true
        }
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for i in 0 ..< couleurs["colors"].count {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
        }
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        tableView.backgroundColor = AppValues.primaryColor
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh(sender:AnyObject)
    {
        aucunProbleme = false
        erreur = false
        distrubtions = []
        if let dataArrets = tpgUrl.getDisruptions() {
            let json = JSON(data: dataArrets)
            if json["disruptions"].count != 0 {
                for x in 0...json["disruptions"].count - 1 {
                    if json["disruptions"][x]["lineCode"].string?.characters.count != 1 && json["disruptions"][x]["lineCode"].string?.characters.first == "T" {
                        
                    }
                    else {
                        distrubtions.append(Perturbations(lineCode: json["disruptions"][x]["lineCode"].string!, title: json["disruptions"][x]["nature"].string!, subTitle: json["disruptions"][x]["consequence"].string!))
                    }
                }
            }
            else {
                aucunProbleme = true
            }
        }
        else {
            erreur = true
        }

        tableView.reloadData()
    }
        
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
	deinit {
		tableView.dg_removePullToRefresh()
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if aucunProbleme == true {
            return 1
        }
        if erreur == true {
            return 1
        }
        return distrubtions.count
    }
    
    func labelToImage(label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("incidentsCell", forIndexPath: indexPath)
        
        if aucunProbleme {
            cell.backgroundColor = UIColor.flatYellowColor()
            let iconeSmile = FAKFontAwesome.smileOIconWithSize(20)
            iconeSmile.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor())
            cell.imageView?.image = iconeSmile.imageWithSize(CGSize(width: 25, height: 25))
            cell.textLabel?.text = "Aucun incident"
            cell.textLabel?.textColor = UIColor.blackColor()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH"
            let heure = Int(dateFormatter.stringFromDate(NSDate()))
            if heure < 6 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !"
            }
            else if heure < 18 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne journée !"
            }
            else if heure < 22 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne soirée !"
            }
            else {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !"
            }
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        else if erreur {
            cell.backgroundColor = UIColor.flatRedColorDark()
            let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
            iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            cell.textLabel?.text = "Pas de réseau !"
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.detailTextLabel!.text = "tpg offline n'est pas connecté au réseau. Il est impossible de charger les perturbations en cours sur le réseau tpg sans réseau."
            cell.detailTextLabel?.textColor = UIColor.whiteColor()
        }
        else {
            cell.backgroundColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]
            cell.textLabel?.text = distrubtions[indexPath.row].title
            cell.textLabel?.textColor = listeColor[distrubtions[indexPath.row].lineCode]
            cell.detailTextLabel!.text = distrubtions[indexPath.row].subTitle
            cell.detailTextLabel?.textColor = listeColor[distrubtions[indexPath.row].lineCode]
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = distrubtions[indexPath.row].lineCode
            labelPictoLigne.textAlignment = .Center
            labelPictoLigne.textColor = listeColor[distrubtions[indexPath.row].lineCode]
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderColor = listeColor[distrubtions[indexPath.row].lineCode]?.CGColor
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.flatOrangeColorDark()
            cell.selectedBackgroundView = backgroundView
        }
        return cell
        
    }
    
    
}
