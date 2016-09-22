//
//  ThermometerTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 10/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Chameleon
import Alamofire
import FontAwesomeKit

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
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        self.refreshTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1))
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        self.refreshTheme()
        self.tableView.reloadData()
        
        var barButtonsItems: [UIBarButtonItem] = []
        
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(ThermometerTableViewController.refresh)))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! loadingCellTableViewCell
            
            cell.activityIndicator.stopAnimating()
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor.flatBlue()
                cell.titleLabel?.textColor = UIColor.white
                cell.subTitleLabel?.textColor = UIColor.white
                cell.activityIndicator.color = UIColor.white
            }
            else {
                cell.backgroundColor = UIColor.white
                cell.titleLabel?.textColor = UIColor.flatBlue()
                cell.subTitleLabel?.textColor = UIColor.flatBlue()
                cell.activityIndicator.color = UIColor.flatBlue()
            }
            cell.titleLabel?.text = "Chargement".localized()
            cell.subTitleLabel?.text = "Merci de patienter".localized()
            cell.accessoryView = nil
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "voirLigneDepartCell", for: indexPath) as! SeeLineTableViewCell
            
            cell.backgroundColor = AppValues.primaryColor
            cell.barDirection.backgroundColor = AppValues.primaryColor
            
            cell.leftTimeLabel.textColor = AppValues.textColor
            if thermometerList[(indexPath as NSIndexPath).row].leftTime != nil {
                if thermometerList[(indexPath as NSIndexPath).row].leftTime == "00" {
                    let busIcon = FAKFontAwesome.busIcon(withSize: 20)!
                    busIcon.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                    cell.leftTimeLabel.attributedText = busIcon.attributedString()
                }
                else {
                    cell.leftTimeLabel.text = "\(thermometerList[(indexPath as NSIndexPath).row].leftTime!)'"
                }
            } else {
                cell.leftTimeLabel.text = ""
            }
            
            cell.titleLabel.textColor = AppValues.textColor
            cell.titleLabel.text = thermometerList[(indexPath as NSIndexPath).row].stop.title
            cell.subTitleLabel.textColor = AppValues.textColor
            cell.subTitleLabel.text = thermometerList[(indexPath as NSIndexPath).row].stop.subTitle
            
            if thermometerList[(indexPath as NSIndexPath).row].connection1 != nil {
                cell.connection1Label.text = String(thermometerList[(indexPath as NSIndexPath).row].connection1!)
                cell.connection1Label.textAlignment = .center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.connection1Label.textColor = AppValues.linesColor[String(thermometerList[(indexPath as NSIndexPath).row].connection1!)]
                    cell.connection1Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection1!)]!
                }
                else {
                    if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection1!)]!, returnFlat: true) == FlatWhite() {
                        cell.connection1Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection1!)]
                        cell.connection1Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.connection1Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection1!)]!.darken(byPercentage: 0.2)
                        cell.connection1Label.backgroundColor = AppValues.primaryColor
                    }
                }
            }
            else{
                cell.connection1Label.text = ""
                cell.connection1Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[(indexPath as NSIndexPath).row].connection2 != nil {
                cell.connection2Label.text = String(thermometerList[(indexPath as NSIndexPath).row].connection2!)
                cell.connection2Label.textAlignment = .center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.connection2Label.textColor = AppValues.linesColor[String(thermometerList[(indexPath as NSIndexPath).row].connection2!)]
                    cell.connection2Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection2!)]!
                }
                else {
                    if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection2!)]!, returnFlat: true) == FlatWhite() {
                        cell.connection2Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection2!)]
                        cell.connection2Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.connection2Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection2!)]!.darken(byPercentage: 0.2)
                        cell.connection2Label.backgroundColor = AppValues.primaryColor
                    }
                    
                }
            }
            else{
                cell.connection2Label.text = ""
                cell.connection2Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[(indexPath as NSIndexPath).row].connection3 != nil {
                cell.connection3Label.text = String(thermometerList[(indexPath as NSIndexPath).row].connection3!)
                cell.connection3Label.textAlignment = .center
                if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                    cell.connection3Label.textColor = AppValues.linesColor[String(thermometerList[(indexPath as NSIndexPath).row].connection3!)]
                    cell.connection3Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection3!)]
                }
                else {
                    if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection3!)]!, returnFlat: true) == FlatWhite() {
                        cell.connection3Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection3!)]
                        cell.connection3Label.backgroundColor = AppValues.primaryColor
                    }
                    else {
                        cell.connection3Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection3!)]!.darken(byPercentage: 0.2)
                        cell.connection3Label.backgroundColor = AppValues.primaryColor
                    }
                    
                }
            }
            else{
                cell.connection3Label.text = ""
                cell.connection3Label.backgroundColor = AppValues.primaryColor
            }
            
            if thermometerList[(indexPath as NSIndexPath).row].connection4 != nil {
                if thermometerList[(indexPath as NSIndexPath).row].connection4! == "more" {
                    cell.connection4Label.text = "..."
                    cell.connection4Label.textAlignment = .center
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        cell.connection4Label.textColor = UIColor.white
                        cell.connection4Label.backgroundColor = UIColor.flatGrayColorDark()
                    }
                    else {
                        cell.connection4Label.textColor = UIColor.flatGrayColorDark()
                        cell.connection4Label.backgroundColor = AppValues.primaryColor
                    }
                } else {
                    cell.connection4Label.text = String(thermometerList[(indexPath as NSIndexPath).row].connection4!)
                    cell.connection4Label.textAlignment = .center
                    if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                        cell.connection4Label.textColor = AppValues.linesColor[String(thermometerList[(indexPath as NSIndexPath).row].connection4!)]
                        cell.connection4Label.backgroundColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection4!)]!
                    }
                    else {
                        if ContrastColorOf(AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection4!)]!, returnFlat: true) == FlatWhite() {
                            cell.connection4Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection4!)]
                            cell.connection4Label.backgroundColor = AppValues.primaryColor
                        }
                        else {
                            cell.connection4Label.textColor = AppValues.linesBackgroundColor[String(thermometerList[(indexPath as NSIndexPath).row].connection4!)]!.darken(byPercentage: 0.2)
                            cell.connection4Label.backgroundColor = AppValues.primaryColor
                        }
                        
                    }
                }
            }
            else{
                cell.connection4Label.text = ""
                cell.connection4Label.backgroundColor = AppValues.primaryColor
            }
            
            if (indexPath as NSIndexPath).row == 0 {
                cell.barDirection.layer.sublayers = []
                let rectanglePath = UIBezierPath(rect: CGRect(x: 10, y: 37, width: 5, height: 33))
                var shapeLayer = CAShapeLayer()
                shapeLayer.path = rectanglePath.cgPath
                shapeLayer.fillColor = AppValues.textColor.cgColor
                cell.barDirection.layer.addSublayer(shapeLayer)
                
                let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2.5, y: 24.5, width: 20, height: 20))
                shapeLayer = CAShapeLayer()
                shapeLayer.path = ovalPath.cgPath
                shapeLayer.strokeColor = AppValues.textColor.cgColor
                shapeLayer.fillColor = UIColor.white.cgColor
                shapeLayer.lineWidth = 3
                cell.barDirection.layer.addSublayer(shapeLayer)
                
            } else if (indexPath as NSIndexPath).row + 1 == thermometerList.count {
                cell.barDirection.layer.sublayers = []
                let rectanglePath = UIBezierPath(rect: CGRect(x: 10, y: 0, width: 5, height: 32))
                var shapeLayer = CAShapeLayer()
                shapeLayer.path = rectanglePath.cgPath
                shapeLayer.fillColor = AppValues.textColor.cgColor
                cell.barDirection.layer.addSublayer(shapeLayer)
                
                if !thermometerList[(indexPath as NSIndexPath).row].isDeflect {
                    let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2.5, y: 24.5, width: 20, height: 20))
                    shapeLayer = CAShapeLayer()
                    shapeLayer.path = ovalPath.cgPath
                    shapeLayer.strokeColor = AppValues.textColor.cgColor
                    shapeLayer.fillColor = UIColor.white.cgColor
                    shapeLayer.lineWidth = 3
                    cell.barDirection.layer.addSublayer(shapeLayer)
                }
            }
            else {
                cell.barDirection.layer.sublayers = []
                let rectanglePath = UIBezierPath(rect: CGRect(x: 10, y: 0, width: 5, height: 70))
                var shapeLayer = CAShapeLayer()
                shapeLayer.path = rectanglePath.cgPath
                shapeLayer.fillColor = AppValues.textColor.cgColor
                cell.barDirection.layer.addSublayer(shapeLayer)
                
                let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2.5, y: 24.5, width: 20, height: 20))
                shapeLayer = CAShapeLayer()
                shapeLayer.path = ovalPath.cgPath
                shapeLayer.strokeColor = AppValues.textColor.cgColor
                shapeLayer.fillColor = AppValues.textColor.cgColor
                shapeLayer.lineWidth = 3
                cell.barDirection.layer.addSublayer(shapeLayer)
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.2)
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.00
    }
    
    func refresh() {
        loading = true
        self.tableView.allowsSelection = false
        tableView.reloadData()
        rowForVisible = -1
        Alamofire.request("http://prod.ivtr-od.tpg.ch/v1/GetThermometer.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "departureCode": departure.code])
            .responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    self.thermometerList = []
                    for (index, subJSON) in json["steps"] {
                        var connectionsList: [String] = []
                        for x in 0...subJSON["stop"]["connections"].count - 1 {
                            if subJSON["stop"]["connections"][x]["lineCode"].int != nil {
                                if connectionsList.index(of: String(subJSON["stop"]["connections"][x]["lineCode"].intValue)) == nil {
                                    connectionsList.append(String(subJSON["stop"]["connections"][x]["lineCode"].intValue))
                                }
                            }
                            else {
                                if connectionsList.index(of: subJSON["stop"]["connections"][x]["lineCode"].stringValue) == nil {
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
                        self.tableView.scrollToRow(at: IndexPath(row: self.rowForVisible, section: 0), at: UITableViewScrollPosition.top, animated: true)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !loading {
            performSegue(withIdentifier: "showLigneArret", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.00
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLigneArret" {
            let departArretTableViewController: DeparturesTableViewController = (segue.destination) as! DeparturesTableViewController
            departArretTableViewController.stop = thermometerList[((self.tableView.indexPathForSelectedRow as IndexPath?)?.row)!].stop
        }
    }
}
