//
//  SeeAllDeparturesViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import AKPickerView_Swift
import SwiftyJSON
import Alamofire
import SCLAlertView
import Async
import ChameleonFramework

class SeeAllDeparturesViewController: UIViewController {
    
    @IBOutlet weak var hourPicker: AKPickerView!
    @IBOutlet weak var departuresCollectionView: UICollectionView!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    
    var line = "1"
    var direction = "Jar.-Botanique"
    var destinationCode = "JAR.-BOTANIQUE"
    var stop: Stop = AppValues.stops[AppValues.stopsKeys[0]]!
    var departuresList: [Departures] = []
    var initialDeparturesList: [Departures] = []
    var hoursList: [Int] = []
    var actualHour = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lineLabel.text = line
        lineLabel.textColor = AppValues.linesColor[line]
        lineLabel.backgroundColor = AppValues.linesBackgroundColor[line]
        
        directionLabel.text = direction
        directionLabel.textColor = AppValues.linesColor[line]
        directionLabel.backgroundColor = AppValues.linesBackgroundColor[line]
        
        departuresCollectionView.allowsSelection = false
        departuresCollectionView.backgroundColor = AppValues.primaryColor
        
        hourPicker.backgroundColor = AppValues.primaryColor
        hourPicker.textColor = AppValues.textColor
        hourPicker.highlightedTextColor = AppValues.textColor
        hourPicker.interitemSpacing = 7
        hourPicker.delegate = self
        hourPicker.dataSource = self
        
        refresh()
        refreshTheme()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        departuresCollectionView.backgroundColor = AppValues.primaryColor
        refreshTheme()
        departuresCollectionView.reloadData()
        
        hourPicker.backgroundColor = AppValues.primaryColor
        hourPicker.textColor = AppValues.textColor
        hourPicker.highlightedTextColor = AppValues.textColor
        hourPicker.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        Async.background {
            self.departuresList = []
            let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
            var path = ""
            if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                switch day.weekday {
                case 7:
                    path = dir.stringByAppendingPathComponent(self.stop.stopCode + "departsSAM.json")
                    break
                case 1:
                    path = dir.stringByAppendingPathComponent(self.stop.stopCode + "departsDIM.json");
                    break
                default:
                    path = dir.stringByAppendingPathComponent(self.stop.stopCode + "departsLUN.json");
                    
                    break
                }
            }
            
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                if self.initialDeparturesList.isEmpty {
                    let dataDeparts = NSData(contentsOfFile: path)
                    let departs = JSON(data: dataDeparts!)
                    for (_, subJson) in departs {
                        if AppValues.linesColor[subJson["ligne"].string!] != nil {
                            self.initialDeparturesList.append(Departures(
                                line: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                destinationCode: "",
                                lineColor: AppValues.linesColor[subJson["ligne"].string!]!,
                                lineBackgroundColor: AppValues.linesBackgroundColor[subJson["ligne"].string!]!,
                                code: nil,
                                leftTime: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                        }
                        else {
                            self.initialDeparturesList.append(Departures(
                                line: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                destinationCode: subJson["line"]["destinationCode"].string!,
                                lineColor: UIColor.whiteColor(),
                                lineBackgroundColor: UIColor.flatGrayColorDark(),
                                code: nil,
                                leftTime: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                        }
                        self.initialDeparturesList.last?.calculerTempsRestant()
                    }
                    
                    self.initialDeparturesList = self.initialDeparturesList.filter({ (depart) -> Bool in
                        if depart.line == self.line && depart.direction == self.direction {
                            return true
                        }
                        return false
                    })
                }
                
                if self.hoursList.isEmpty {
                    for depart in self.initialDeparturesList {
                        if self.hoursList.indexOf((depart.dateCompenents?.hour)!) == nil {
                            self.hoursList.append((depart.dateCompenents?.hour)!)
                        }
                    }
                    
                    
                    self.actualHour = self.hoursList[0]
                }
                
                self.departuresList = self.initialDeparturesList.filter({ (depart) -> Bool in
                    if depart.dateCompenents?.hour == self.actualHour {
                        return true
                    }
                    return false
                })
            }
            else {
                if self.initialDeparturesList.isEmpty {
                    Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": self.stop.stopCode, "lineCode": self.line, "destinationCode": self.destinationCode]).responseJSON { response in
                        if let data = response.result.value {
                            let departs = JSON(data)
                            for (_, subjson) in departs["departures"] {
                                if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                                    self.initialDeparturesList.append(Departures(
                                        line: subjson["line"]["lineCode"].string!,
                                        direction: subjson["line"]["destinationName"].string!,
                                        destinationCode: subjson["line"]["destinationCode"].string!,
                                        lineColor: UIColor.whiteColor(),
                                        lineBackgroundColor: UIColor.flatGrayColor(),
                                        
                                        code: String(subjson["departureCode"].intValue ?? 0),
                                        leftTime: subjson["waitingTime"].string!,
                                        timestamp: subjson["timestamp"].string
                                        ))
                                }
                                else {
                                    self.initialDeparturesList.append(Departures(
                                        line: subjson["line"]["lineCode"].string!,
                                        direction: subjson["line"]["destinationName"].string!,
                                        destinationCode: subjson["line"]["destinationCode"].string!,
                                        lineColor: AppValues.linesColor[subjson["line"]["lineCode"].string!]!,
                                        lineBackgroundColor: AppValues.linesBackgroundColor[subjson["line"]["lineCode"].string!]!,
                                        
                                        code: String(subjson["departureCode"].intValue ?? 0),
                                        leftTime: subjson["waitingTime"].string!,
                                        timestamp: subjson["timestamp"].string
                                        ))
                                }
                                self.initialDeparturesList.last?.calculerTempsRestant()
                            }
                            
                            if self.hoursList.isEmpty {
                                for depart in self.initialDeparturesList {
                                    if self.hoursList.indexOf((depart.dateCompenents?.hour)!) == nil {
                                        self.hoursList.append((depart.dateCompenents?.hour)!)
                                    }
                                }
                                
                                self.hourPicker.reloadData()
                                self.actualHour = self.hoursList[0]
                            }
                            
                            self.departuresList = self.initialDeparturesList.filter({ (depart) -> Bool in
                                if depart.dateCompenents?.hour == self.actualHour {
                                    return true
                                }
                                return false
                            })
                        }
                        else {
                            SCLAlertView().showError("Pas de réseau", subTitle: "Nous ne pouvons charger la totalité des départs car vous n'avez pas télécharger les départs (si vous avez acheté le mode premium) et vous n'êtes pas connecté à internet", closeButtonTitle: "OK").setDismissBlock({
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                    }
                }
                else {
                    self.departuresList = self.initialDeparturesList.filter({ (depart) -> Bool in
                        if depart.dateCompenents?.hour == self.actualHour {
                            return true
                        }
                        return false
                    })
                }
            }
            }.main {
                self.hourPicker.reloadData()
                self.departuresCollectionView.reloadData()
        }
    }
}

extension SeeAllDeparturesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.departuresList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tousLesDepartsCell", forIndexPath: indexPath) as! AllDeparturesCollectionViewCell
        
        cell.title.text = NSDateFormatter.localizedStringFromDate(NSDate(components: departuresList[indexPath.row].dateCompenents!), dateStyle: .NoStyle, timeStyle: .ShortStyle)
        cell.title.textColor = AppValues.textColor
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            cell.backgroundColor = AppValues.primaryColor.lightenByPercentage(0.1)
        }
        else {
            cell.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.1)
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.width / 4, height: 50)
    }
}

extension SeeAllDeparturesViewController: AKPickerViewDataSource, AKPickerViewDelegate {
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return hoursList.count
    }
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return "\(hoursList[item])h"
    }
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        self.actualHour = hoursList[item]
        refresh()
    }
}