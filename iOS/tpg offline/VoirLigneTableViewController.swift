//
//  VoirLigneTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 10/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import DGElasticPullToRefresh
import Alamofire

class VoirLigneTableViewController: UITableViewController {
    
    var depart: Departs! = nil
    var thermometerList: [Thermometer]! = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    var chargement: Bool = false
    var rowForVisible = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for i in 0 ..< couleurs["colors"].count {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string, withAlpha: 1)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string, withAlpha: 1)
        }
        
        if depart != nil {
            self.title = "Ligne".localized() + " \(depart.ligne)"
            refresh()
        }
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refresh()
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        self.actualiserTheme()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        self.actualiserTheme()
        self.tableView.reloadData()
        
        var barButtonsItems: [UIBarButtonItem] = []
        
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(VoirLigneTableViewController.refresh)))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chargement {
            return 1
        }
        else {
            return thermometerList.count
        }
    }
    
    deinit {
        tableView?.dg_removePullToRefresh()
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
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("voirLigneDepartCell", forIndexPath: indexPath) as! VoirLigneTableViewCell
            
            cell.backgroundColor = AppValues.primaryColor
            cell.barDirection.backgroundColor = AppValues.primaryColor
            
            cell.tempsRestantLabel.textColor = AppValues.textColor
            if thermometerList[indexPath.row].tempsRestant != nil {
                if thermometerList[indexPath.row].tempsRestant == "00" {
                    let iconeBus = FAKFontAwesome.busIconWithSize(20)
                    iconeBus.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.tempsRestantLabel.attributedText = iconeBus.attributedString()
                }
                else {
                    cell.tempsRestantLabel.text = "\(thermometerList[indexPath.row].tempsRestant!)'"
                }
            } else {
                cell.tempsRestantLabel.text = ""
            }
            
            cell.titreLabel.textColor = AppValues.textColor
            cell.titreLabel.text = thermometerList[indexPath.row].arret.titre
            cell.sousTitreLabel.textColor = AppValues.textColor
            cell.sousTitreLabel.text = thermometerList[indexPath.row].arret.sousTitre
            
            if thermometerList[indexPath.row].correspondance1 != nil {
                cell.correspondance1Label.text = String(thermometerList[indexPath.row].correspondance1!)
                cell.correspondance1Label.textAlignment = .Center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.correspondance1Label.textColor = listeColor[String(thermometerList[indexPath.row].correspondance1!)]
                    cell.correspondance1Label.backgroundColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance1!)]!
                }
                else {
                    if ContrastColorOf(listeBackgroundColor[String(thermometerList[indexPath.row].correspondance1!)]!, returnFlat: true) == FlatWhite() {
                        cell.correspondance1Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance1!)]
                        cell.correspondance1Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.correspondance1Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance1!)]!.darkenByPercentage(0.2)
                        cell.correspondance1Label.backgroundColor = AppValues.primaryColor
                    }
                }
            }
            else{
                cell.correspondance1Label.text = ""
                cell.correspondance1Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[indexPath.row].correspondance2 != nil {
                cell.correspondance2Label.text = String(thermometerList[indexPath.row].correspondance2!)
                cell.correspondance2Label.textAlignment = .Center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.correspondance2Label.textColor = listeColor[String(thermometerList[indexPath.row].correspondance2!)]
                    cell.correspondance2Label.backgroundColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance2!)]!
                }
                else {
                    if ContrastColorOf(listeBackgroundColor[String(thermometerList[indexPath.row].correspondance2!)]!, returnFlat: true) == FlatWhite() {
                        cell.correspondance2Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance2!)]
                        cell.correspondance2Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.correspondance2Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance2!)]!.darkenByPercentage(0.2)
                        cell.correspondance2Label.backgroundColor = AppValues.primaryColor
                    }
                    
                }
            }
            else{
                cell.correspondance2Label.text = ""
                cell.correspondance2Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[indexPath.row].correspondance3 != nil {
                cell.correspondance3Label.text = String(thermometerList[indexPath.row].correspondance3!)
                cell.correspondance3Label.textAlignment = .Center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.correspondance3Label.textColor = listeColor[String(thermometerList[indexPath.row].correspondance3!)]
                    cell.correspondance3Label.backgroundColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance3!)]
                }
                else {
                    if ContrastColorOf(listeBackgroundColor[String(thermometerList[indexPath.row].correspondance3!)]!, returnFlat: true) == FlatWhite() {
                        cell.correspondance3Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance3!)]
                        cell.correspondance3Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.correspondance3Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance3!)]!.darkenByPercentage(0.2)
                        cell.correspondance3Label.backgroundColor = AppValues.primaryColor
                    }
                    
                }
            }
            else{
                cell.correspondance3Label.text = ""
                cell.correspondance3Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[indexPath.row].correspondance4 != nil {
                if thermometerList[indexPath.row].correspondance4! == "more" {
                    cell.correspondance4Label.text = "..."
                    cell.correspondance4Label.textAlignment = .Center
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        cell.correspondance4Label.textColor = UIColor.whiteColor()
                        cell.correspondance4Label.backgroundColor = UIColor.flatGrayColorDark()
                    }
                    else {
                        cell.correspondance4Label.textColor = UIColor.flatGrayColorDark()
                        cell.correspondance4Label.backgroundColor = AppValues.primaryColor
                    }
                } else {
                    cell.correspondance4Label.text = String(thermometerList[indexPath.row].correspondance4!)
                    cell.correspondance4Label.textAlignment = .Center
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        cell.correspondance4Label.textColor = listeColor[String(thermometerList[indexPath.row].correspondance4!)]
                        cell.correspondance4Label.backgroundColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance4!)]!
                    }
                    else {
                        if ContrastColorOf(listeBackgroundColor[String(thermometerList[indexPath.row].correspondance4!)]!, returnFlat: true) == FlatWhite() {
                            cell.correspondance4Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance4!)]
                            cell.correspondance4Label.backgroundColor = AppValues.primaryColor
                        }
                        else {
                            cell.correspondance4Label.textColor = listeBackgroundColor[String(thermometerList[indexPath.row].correspondance4!)]!.darkenByPercentage(0.2)
                            cell.correspondance4Label.backgroundColor = AppValues.primaryColor
                        }
                        
                    }
                }
            }
            else{
                cell.correspondance4Label.text = ""
                cell.correspondance4Label.backgroundColor = AppValues.primaryColor
            }
            
            if indexPath.row == 0 {
                cell.barDirection.layer.sublayers = []
                let rectanglePath = UIBezierPath(rect: CGRectMake(10, 37, 5, 33))
                var shapeLayer = CAShapeLayer()
                shapeLayer.path = rectanglePath.CGPath
                shapeLayer.fillColor = AppValues.textColor.CGColor
                cell.barDirection.layer.addSublayer(shapeLayer)
                
                let ovalPath = UIBezierPath(ovalInRect: CGRectMake(2.5, 24.5, 20, 20))
                shapeLayer = CAShapeLayer()
                shapeLayer.path = ovalPath.CGPath
                shapeLayer.strokeColor = AppValues.textColor.CGColor
                shapeLayer.fillColor = UIColor.whiteColor().CGColor
                shapeLayer.lineWidth = 3
                cell.barDirection.layer.addSublayer(shapeLayer)
                
            } else if indexPath.row + 1 == thermometerList.count {
                cell.barDirection.layer.sublayers = []
                let rectanglePath = UIBezierPath(rect: CGRect(x: 10, y: 0, width: 5, height: 32))
                var shapeLayer = CAShapeLayer()
                shapeLayer.path = rectanglePath.CGPath
                shapeLayer.fillColor = AppValues.textColor.CGColor
                cell.barDirection.layer.addSublayer(shapeLayer)
                
                if !thermometerList[indexPath.row].devie {
                    let ovalPath = UIBezierPath(ovalInRect: CGRect(x: 2.5, y: 24.5, width: 20, height: 20))
                    shapeLayer = CAShapeLayer()
                    shapeLayer.path = ovalPath.CGPath
                    shapeLayer.strokeColor = AppValues.textColor.CGColor
                    shapeLayer.fillColor = UIColor.whiteColor().CGColor
                    shapeLayer.lineWidth = 3
                    cell.barDirection.layer.addSublayer(shapeLayer)
                }
            }
            else {
                cell.barDirection.layer.sublayers = []
                let rectanglePath = UIBezierPath(rect: CGRectMake(10, 0, 5, 70))
                var shapeLayer = CAShapeLayer()
                shapeLayer.path = rectanglePath.CGPath
                shapeLayer.fillColor = AppValues.textColor.CGColor
                cell.barDirection.layer.addSublayer(shapeLayer)
                
                let ovalPath = UIBezierPath(ovalInRect: CGRectMake(2.5, 24.5, 20, 20))
                shapeLayer = CAShapeLayer()
                shapeLayer.path = ovalPath.CGPath
                shapeLayer.strokeColor = AppValues.textColor.CGColor
                shapeLayer.fillColor = AppValues.textColor.CGColor
                shapeLayer.lineWidth = 3
                cell.barDirection.layer.addSublayer(shapeLayer)
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.2)
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func refresh() {
        chargement = true
        self.tableView.allowsSelection = false
        tableView.reloadData()
        rowForVisible = -1
        Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetThermometer.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "departureCode": depart.code])
            .responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    self.thermometerList = []
                    for (index, subJSON) in json["steps"] {
                        var listeCorrespondances: [String] = []
                        for x in 0...subJSON["stop"]["connections"].count - 1 {
                            if subJSON["stop"]["connections"][x]["lineCode"].int != nil {
                                if listeCorrespondances.indexOf(String(subJSON["stop"]["connections"][x]["lineCode"].intValue)) == nil {
                                    listeCorrespondances.append(String(subJSON["stop"]["connections"][x]["lineCode"].intValue))
                                }
                            }
                            else {
                                if listeCorrespondances.indexOf(subJSON["stop"]["connections"][x]["lineCode"].stringValue) == nil {
                                    listeCorrespondances.append(subJSON["stop"]["connections"][x]["lineCode"].stringValue)
                                }
                            }
                        }
                        if listeCorrespondances.count > 4 {
                            self.thermometerList.append(Thermometer(arret: AppValues.arrets[AppValues.stopCodeToArret[subJSON["stop"]["stopCode"].stringValue]!], tempsRestant: subJSON["arrivalTime"].string, devie: subJSON["deviation"].boolValue, correspondance1: listeCorrespondances[0], correspondance2: listeCorrespondances[1], correspondance3: listeCorrespondances[2], correspondance4: "more"))
                        } else if listeCorrespondances.count == 4  {
                            self.thermometerList.append(Thermometer(arret: AppValues.arrets[AppValues.stopCodeToArret[subJSON["stop"]["stopCode"].stringValue]!], tempsRestant: subJSON["arrivalTime"].string, devie: subJSON["deviation"].boolValue, correspondance1: listeCorrespondances[0], correspondance2: listeCorrespondances[1], correspondance3: listeCorrespondances[2], correspondance4: listeCorrespondances[3]))
                        } else if listeCorrespondances.count == 3  {
                            self.thermometerList.append(Thermometer(arret: AppValues.arrets[AppValues.stopCodeToArret[subJSON["stop"]["stopCode"].stringValue]!], tempsRestant: subJSON["arrivalTime"].string, devie: subJSON["deviation"].boolValue, correspondance1: listeCorrespondances[0], correspondance2: listeCorrespondances[1], correspondance3: listeCorrespondances[2], correspondance4: nil))
                        } else if listeCorrespondances.count == 2  {
                            self.thermometerList.append(Thermometer(arret: AppValues.arrets[AppValues.stopCodeToArret[subJSON["stop"]["stopCode"].stringValue]!], tempsRestant: subJSON["arrivalTime"].string, devie: subJSON["deviation"].boolValue, correspondance1: listeCorrespondances[0], correspondance2: listeCorrespondances[1], correspondance3: nil, correspondance4: nil))
                        } else if listeCorrespondances.count == 1  {
                            self.thermometerList.append(Thermometer(arret: AppValues.arrets[AppValues.stopCodeToArret[subJSON["stop"]["stopCode"].stringValue]!], tempsRestant: subJSON["arrivalTime"].string, devie: subJSON["deviation"].boolValue, correspondance1: listeCorrespondances[0], correspondance2: nil, correspondance3: nil, correspondance4: nil))
                        } else {
                            self.thermometerList.append(Thermometer(arret: AppValues.arrets[AppValues.stopCodeToArret[subJSON["stop"]["stopCode"].stringValue]!], tempsRestant: subJSON["arrivalTime"].string, devie: subJSON["deviation"].boolValue, correspondance1: nil, correspondance2: nil, correspondance3: nil, correspondance4: nil))
                        }
                        if subJSON["arrivalTime"].string != nil && self.rowForVisible == -1 {
                            self.rowForVisible = Int(index)!
                        }
                    }
                    self.chargement = false
                    self.tableView.allowsSelection = true
                    self.tableView.reloadData()
                    self.tableView.dg_stopLoading()
                    if self.rowForVisible != -1 {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.rowForVisible, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    }
                }
                else {
                    self.thermometerList = []
                    self.tableView.allowsSelection = false
                    self.chargement = false
                    self.tableView.reloadData()
                    self.tableView.dg_stopLoading()
                }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !chargement {
            performSegueWithIdentifier("showLigneArret", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLigneArret" {
            let departArretTableViewController:DepartsArretTableViewController = (segue.destinationViewController) as! DepartsArretTableViewController
            departArretTableViewController.arret = thermometerList[(self.tableView.indexPathForSelectedRow?.row)!].arret
        }
    }
}
