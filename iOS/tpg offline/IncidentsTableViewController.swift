//
//  IncidentsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import DGElasticPullToRefresh
import Alamofire

class IncidentsTableViewController: UITableViewController {
    let defaults = NSUserDefaults.standardUserDefaults()
    var distrubtions: [Perturbations] = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    var erreur = false
    var aucunProbleme = false
    var chargement: Bool = false
    
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
        
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for i in 0 ..< couleurs["colors"].count {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
        }
        refresh(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        actualiserTheme()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh(sender:AnyObject)
    {
        aucunProbleme = false
        erreur = false
        distrubtions = []
        chargement = true
        tableView.reloadData()
        
        Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetDisruptions.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b"])
            .responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    if json["disruptions"].count != 0 {
                        for x in 0...json["disruptions"].count - 1 {
                            if self.listeColor[json["disruptions"][x]["lineCode"].string!] != nil {
                                self.distrubtions.append(Perturbations(lineCode: json["disruptions"][x]["lineCode"].string!, title: json["disruptions"][x]["nature"].string!, subTitle: json["disruptions"][x]["consequence"].string!))
                            }
                        }
                    }
                    else {
                        self.aucunProbleme = true
                    }
                    self.chargement = false
                    self.tableView.reloadData()
                }
                else {
                    self.erreur = true
                    self.tableView.reloadData()
                }
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
        if chargement {
            return 1
        }
        else if aucunProbleme == true {
            return 1
        }
        else if erreur == true {
            return 1
        }
        else {
            return distrubtions.count
        }
    }
    
    func labelToImage(label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if chargement == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell", forIndexPath: indexPath) as! loadingCellTableViewCell
            
            cell.activityIndicator.stopAnimation()
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor.flatBlueColor()
                cell.titleLabel?.textColor = UIColor.whiteColor()
                cell.subTitleLabel?.textColor = UIColor.whiteColor()
                cell.activityIndicator.color = UIColor.whiteColor()
            }
            else {
                cell.backgroundColor = UIColor.whiteColor()
                cell.titleLabel?.textColor = UIColor.flatBlueColor()
                cell.subTitleLabel?.textColor = UIColor.flatBlueColor()
                cell.activityIndicator.color = UIColor.flatBlueColor()
            }
            cell.titleLabel?.text = "Chargement".localized()
            cell.subTitleLabel?.text = "Merci de patienter".localized()
            cell.accessoryView = nil
            
            cell.activityIndicator.startAnimation()

            return cell
        }
        else if aucunProbleme {
            let cell = tableView.dequeueReusableCellWithIdentifier("incidentsCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Aucun incident".localized()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH"
            let heure = Int(dateFormatter.stringFromDate(NSDate()))
            if heure < 6 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !".localized()
            }
            else if heure < 18 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne journée !".localized()
            }
            else if heure < 22 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne soirée !".localized()
            }
            else {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !".localized()
            }
            
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.detailTextLabel?.textColor = UIColor.blackColor()
                cell.backgroundColor = UIColor.flatYellowColor()
                
                let iconeSmile = FAKFontAwesome.smileOIconWithSize(20)
                iconeSmile.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor())
                cell.imageView?.image = iconeSmile.imageWithSize(CGSize(width: 25, height: 25))
            }
            else {
                cell.textLabel?.textColor = UIColor.flatYellowColorDark()
                cell.detailTextLabel?.textColor = UIColor.flatYellowColorDark()
                cell.backgroundColor = UIColor.flatWhiteColor()
                
                let iconeSmile = FAKFontAwesome.smileOIconWithSize(20)
                iconeSmile.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatYellowColorDark())
                cell.imageView?.image = iconeSmile.imageWithSize(CGSize(width: 25, height: 25))
            }
            return cell
        }
        else if erreur {
            let cell = tableView.dequeueReusableCellWithIdentifier("incidentsCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Pas de réseau !".localized()
            
            cell.detailTextLabel!.text = "tpg offline n'est pas connecté au réseau. Il est impossible de charger les perturbations en cours sur le réseau tpg sans réseau.".localized()
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.detailTextLabel?.textColor = UIColor.whiteColor()
                cell.backgroundColor = UIColor.flatRedColorDark()
                
                let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            }
            else {
                cell.textLabel?.textColor = UIColor.flatRedColorDark()
                cell.detailTextLabel?.textColor = UIColor.flatRedColorDark()
                cell.backgroundColor = UIColor.flatWhiteColor()
                
                let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatRedColorDark())
                cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("incidentsCell", forIndexPath: indexPath)
            cell.textLabel?.text = distrubtions[indexPath.row].title
            cell.detailTextLabel!.text = distrubtions[indexPath.row].subTitle
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = distrubtions[indexPath.row].lineCode
            labelPictoLigne.textAlignment = .Center
            
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]
                cell.textLabel?.textColor = listeColor[distrubtions[indexPath.row].lineCode]
                cell.detailTextLabel?.textColor = listeColor[distrubtions[indexPath.row].lineCode]
                labelPictoLigne.textColor = listeColor[distrubtions[indexPath.row].lineCode]
                labelPictoLigne.layer.borderColor = listeColor[distrubtions[indexPath.row].lineCode]?.CGColor
            }
            else {
                if ContrastColorOf(listeBackgroundColor[distrubtions[indexPath.row].lineCode]!, returnFlat: true) == FlatWhite() {
                    cell.backgroundColor = UIColor.flatWhiteColor()
                    cell.textLabel?.textColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]
                    cell.detailTextLabel?.textColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]
                    labelPictoLigne.textColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]
                    labelPictoLigne.layer.borderColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]?.CGColor
                }
                else {
                    cell.backgroundColor = UIColor.flatWhiteColor()
                    cell.textLabel?.textColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]!.darkenByPercentage(0.2)
                    cell.detailTextLabel?.textColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]!.darkenByPercentage(0.2)
                    labelPictoLigne.textColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]!.darkenByPercentage(0.2)
                    labelPictoLigne.layer.borderColor = listeBackgroundColor[distrubtions[indexPath.row].lineCode]?.darkenByPercentage(0.2).CGColor
                }
                
            }
            
            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image
            return cell
        }
        
    }
    
    
}
