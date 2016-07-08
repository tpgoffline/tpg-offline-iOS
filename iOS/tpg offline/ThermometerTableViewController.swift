//
//  ThermometerTableViewController.swift
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

class ThermometerTableViewController: UITableViewController {
    
    var departure: Departures! = nil
    var thermometerList: [Thermometer]! = []
    var loading: Bool = false
    var rowForVisible = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if departure != nil {
            self.title = "Ligne".localized() + " \(departure.line)"
            refresh()
        }
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refresh()
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darkenByPercentage(0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        self.refreshTheme()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darkenByPercentage(0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        self.refreshTheme()
        self.tableView.reloadData()
        
        var barButtonsItems: [UIBarButtonItem] = []
        
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(ThermometerTableViewController.refresh)))
        
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
        if loading {
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
        if loading == true {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("voirLigneDepartCell", forIndexPath: indexPath) as! SeeLineTableViewCell
            
            cell.backgroundColor = AppValues.primaryColor
            cell.barDirection.backgroundColor = AppValues.primaryColor
            
            cell.leftTimeLabel.textColor = AppValues.textColor
            if thermometerList[indexPath.row].leftTime != nil {
                if thermometerList[indexPath.row].leftTime == "00" {
                    let busIcon = FAKFontAwesome.busIconWithSize(20)
                    busIcon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.leftTimeLabel.attributedText = busIcon.attributedString()
                }
                else {
                    cell.leftTimeLabel.text = "\(thermometerList[indexPath.row].leftTime!)'"
                }
            } else {
                cell.leftTimeLabel.text = ""
            }
            
            cell.titleLabel.textColor = AppValues.textColor
            cell.titleLabel.text = thermometerList[indexPath.row].stop.title
            cell.subTitleLabel.textColor = AppValues.textColor
            cell.subTitleLabel.text = thermometerList[indexPath.row].stop.subTitle
            
            if thermometerList[indexPath.row].connection1 != nil {
                cell.connection1Label.text = String(thermometerList[indexPath.row].connection1!)
                cell.connection1Label.textAlignment = .Center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.connection1Label.textColor = AppValues.linesColor[String(thermometerList[indexPath.row].connection1!)]
                    cell.connection1Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection1!)]!
                }
                else {
                    if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection1!)]!, returnFlat: true) == FlatWhite() {
                        cell.connection1Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection1!)]
                        cell.connection1Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.connection1Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection1!)]!.darkenByPercentage(0.2)
                        cell.connection1Label.backgroundColor = AppValues.primaryColor
                    }
                }
            }
            else{
                cell.connection1Label.text = ""
                cell.connection1Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[indexPath.row].connection2 != nil {
                cell.connection2Label.text = String(thermometerList[indexPath.row].connection2!)
                cell.connection2Label.textAlignment = .Center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.connection2Label.textColor = AppValues.linesColor[String(thermometerList[indexPath.row].connection2!)]
                    cell.connection2Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection2!)]!
                }
                else {
                    if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection2!)]!, returnFlat: true) == FlatWhite() {
                        cell.connection2Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection2!)]
                        cell.connection2Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.connection2Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection2!)]!.darkenByPercentage(0.2)
                        cell.connection2Label.backgroundColor = AppValues.primaryColor
                    }
                    
                }
            }
            else{
                cell.connection2Label.text = ""
                cell.connection2Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[indexPath.row].connection3 != nil {
                cell.connection3Label.text = String(thermometerList[indexPath.row].connection3!)
                cell.connection3Label.textAlignment = .Center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.connection3Label.textColor = AppValues.linesColor[String(thermometerList[indexPath.row].connection3!)]
                    cell.connection3Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection3!)]
                }
                else {
                    if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection3!)]!, returnFlat: true) == FlatWhite() {
                        cell.connection3Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection3!)]
                        cell.connection3Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.connection3Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection3!)]!.darkenByPercentage(0.2)
                        cell.connection3Label.backgroundColor = AppValues.primaryColor
                    }
                    
                }
            }
            else{
                cell.connection3Label.text = ""
                cell.connection3Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[indexPath.row].connection4 != nil {
                if thermometerList[indexPath.row].connection4! == "more" {
                    cell.connection4Label.text = "..."
                    cell.connection4Label.textAlignment = .Center
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        cell.connection4Label.textColor = UIColor.whiteColor()
                        cell.connection4Label.backgroundColor = UIColor.flatGrayColorDark()
                    }
                    else {
                        cell.connection4Label.textColor = UIColor.flatGrayColorDark()
                        cell.connection4Label.backgroundColor = AppValues.primaryColor
                    }
                } else {
                    cell.connection4Label.text = String(thermometerList[indexPath.row].connection4!)
                    cell.connection4Label.textAlignment = .Center
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        cell.connection4Label.textColor = AppValues.linesColor[String(thermometerList[indexPath.row].connection4!)]
                        cell.connection4Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection4!)]!
                    }
                    else {
                        if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection4!)]!, returnFlat: true) == FlatWhite() {
                            cell.connection4Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection4!)]
                            cell.connection4Label.backgroundColor = AppValues.primaryColor
                        }
                        else {
                            cell.connection4Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[indexPath.row].connection4!)]!.darkenByPercentage(0.2)
                            cell.connection4Label.backgroundColor = AppValues.primaryColor
                        }
                        
                    }
                }
            }
            else{
                cell.connection4Label.text = ""
                cell.connection4Label.backgroundColor = AppValues.primaryColor
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
                
                if !thermometerList[indexPath.row].isDeflect {
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
        return 70.00
    }
    
    func refresh() {
        loading = true
        self.tableView.allowsSelection = false
        tableView.reloadData()
        rowForVisible = -1
        Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetThermometer.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "departureCode": departure.code])
            .responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    self.thermometerList = []
                    for (index, subJSON) in json["steps"] {
                        var connectionsList: [String] = []
                        for x in 0...subJSON["stop"]["connections"].count - 1 {
                            if subJSON["stop"]["connections"][x]["lineCode"].int != nil {
                                if connectionsList.indexOf(String(subJSON["stop"]["connections"][x]["lineCode"].intValue)) == nil {
                                    connectionsList.append(String(subJSON["stop"]["connections"][x]["lineCode"].intValue))
                                }
                            }
                            else {
                                if connectionsList.indexOf(subJSON["stop"]["connections"][x]["lineCode"].stringValue) == nil {
                                    connectionsList.append(subJSON["stop"]["connections"][x]["lineCode"].stringValue)
                                }
                            }
                        }
                        if connectionsList.count > 4 {
                            self.thermometerList.append(Thermometer(stop: AppValues.stops[AppValues.stopCodeToStopItem[subJSON["stop"]["stopCode"].stringValue]!], leftTime: subJSON["arrivalTime"].string, isDeflect: subJSON["deviation"].boolValue, connection1: connectionsList[0], connection2: connectionsList[1], connection3: connectionsList[2], connection4: "more"))
                        } else if connectionsList.count == 4  {
                            self.thermometerList.append(Thermometer(stop: AppValues.stops[AppValues.stopCodeToStopItem[subJSON["stop"]["stopCode"].stringValue]!], leftTime: subJSON["arrivalTime"].string, isDeflect: subJSON["deviation"].boolValue, connection1: connectionsList[0], connection2: connectionsList[1], connection3: connectionsList[2], connection4: connectionsList[3]))
                        } else if connectionsList.count == 3  {
                            self.thermometerList.append(Thermometer(stop: AppValues.stops[AppValues.stopCodeToStopItem[subJSON["stop"]["stopCode"].stringValue]!], leftTime: subJSON["arrivalTime"].string, isDeflect: subJSON["deviation"].boolValue, connection1: connectionsList[0], connection2: connectionsList[1], connection3: connectionsList[2], connection4: nil))
                        } else if connectionsList.count == 2  {
                            self.thermometerList.append(Thermometer(stop: AppValues.stops[AppValues.stopCodeToStopItem[subJSON["stop"]["stopCode"].stringValue]!], leftTime: subJSON["arrivalTime"].string, isDeflect: subJSON["deviation"].boolValue, connection1: connectionsList[0], connection2: connectionsList[1], connection3: nil, connection4: nil))
                        } else if connectionsList.count == 1  {
                            self.thermometerList.append(Thermometer(stop: AppValues.stops[AppValues.stopCodeToStopItem[subJSON["stop"]["stopCode"].stringValue]!], leftTime: subJSON["arrivalTime"].string, isDeflect: subJSON["deviation"].boolValue, connection1: connectionsList[0], connection2: nil, connection3: nil, connection4: nil))
                        } else {
                            self.thermometerList.append(Thermometer(stop: AppValues.stops[AppValues.stopCodeToStopItem[subJSON["stop"]["stopCode"].stringValue]!], leftTime: subJSON["arrivalTime"].string, isDeflect: subJSON["deviation"].boolValue, connection1: nil, connection2: nil, connection3: nil, connection4: nil))
                        }
                        if subJSON["arrivalTime"].string != nil && self.rowForVisible == -1 {
                            self.rowForVisible = Int(index)!
                        }
                    }
                    self.loading = false
                    self.tableView.allowsSelection = true
                    self.tableView.reloadData()
                    self.tableView.dg_stopLoading()
                    if self.rowForVisible != -1 {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.rowForVisible, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    }
                }
                else {
                    AppValues.logger.error(response.result.error)
                    self.thermometerList = []
                    self.tableView.allowsSelection = false
                    self.loading = false
                    self.tableView.reloadData()
                    self.tableView.dg_stopLoading()
                }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !loading {
            performSegueWithIdentifier("showLigneArret", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.00
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLigneArret" {
            let departArretTableViewController: DeparturesTableViewController = (segue.destinationViewController) as! DeparturesTableViewController
            departArretTableViewController.stop = thermometerList[(self.tableView.indexPathForSelectedRow?.row)!].stop
        }
    }
}
