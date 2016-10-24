//
//  SeeAllDeparturesViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Alamofire
import Chameleon

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
        directionLabel.text = direction
        
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            lineLabel.textColor = AppValues.linesColor[line]
            lineLabel.backgroundColor = AppValues.linesBackgroundColor[line]
            
            directionLabel.textColor = AppValues.linesColor[line]
            directionLabel.backgroundColor = AppValues.linesBackgroundColor[line]
        }
        else {
            if ContrastColorOf(AppValues.linesBackgroundColor[line]!, returnFlat: true) == FlatWhite() {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]
                lineLabel.backgroundColor = AppValues.primaryColor
                
                directionLabel.textColor = AppValues.linesBackgroundColor[line]
                directionLabel.backgroundColor = AppValues.primaryColor
            }
            else {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(byPercentage: 0.2)
                lineLabel.backgroundColor = AppValues.primaryColor
                
                directionLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(byPercentage: 0.2)
                directionLabel.backgroundColor = AppValues.primaryColor
            }
            
        }
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()
        
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            lineLabel.textColor = AppValues.linesColor[line]
            lineLabel.backgroundColor = AppValues.linesBackgroundColor[line]
            
            directionLabel.textColor = AppValues.linesColor[line]
            directionLabel.backgroundColor = AppValues.linesBackgroundColor[line]
        }
        else {
            if ContrastColorOf(AppValues.linesBackgroundColor[line]!, returnFlat: true) == FlatWhite() {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]
                lineLabel.backgroundColor = AppValues.primaryColor
                
                directionLabel.textColor = AppValues.linesBackgroundColor[line]
                directionLabel.backgroundColor = AppValues.primaryColor
            }
            else {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(byPercentage: 0.2)
                lineLabel.backgroundColor = AppValues.primaryColor
                
                directionLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(byPercentage: 0.2)
                directionLabel.backgroundColor = AppValues.primaryColor
            }
            
        }
        
        departuresCollectionView.backgroundColor = AppValues.primaryColor
        
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
            
            if self.initialDeparturesList.isEmpty {
                Alamofire.request("http://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": self.stop.stopCode, "lineCode": self.line, "destinationCode": self.destinationCode]).responseJSON { response in
                    if let data = response.result.value {
                        let departs = JSON(data)
                        for (_, subjson) in departs["departures"] {
                            if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                                self.initialDeparturesList.append(Departures(
                                    line: subjson["line"]["lineCode"].string!,
                                    direction: subjson["line"]["destinationName"].string!,
                                    destinationCode: subjson["line"]["destinationCode"].string!,
                                    lineColor: UIColor.white,
                                    lineBackgroundColor: UIColor.flatGray(),
                                    
                                    code: String(subjson["departureCode"].int ?? 0),
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
                                    
                                    code: String(subjson["departureCode"].int ?? 0),
                                    leftTime: subjson["waitingTime"].string!,
                                    timestamp: subjson["timestamp"].string
                                ))
                            }
                            self.initialDeparturesList.last?.calculerTempsRestant()
                        }
                        
                        if self.hoursList.isEmpty {
                            for depart in self.initialDeparturesList {
                                if self.hoursList.index(of: (depart.dateCompenents?.hour)!) == nil {
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
                        let day = Calendar.current.dateComponents([.weekday], from: Date())
                        var path: URL
                        let dir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
                        switch day.weekday! {
                        case 7:
                            path = dir.appendingPathComponent(self.stop.stopCode + "departsSAM.json")
                            break
                        case 1:
                            path = dir.appendingPathComponent(self.stop.stopCode + "departsDIM.json");
                            break
                        default:
                            path = dir.appendingPathComponent(self.stop.stopCode + "departsLUN.json");
                            
                            break
                        }
                        
                        if FileManager.default.fileExists(atPath: path.absoluteString) {
                            if self.initialDeparturesList.isEmpty {
                                let dataDeparts = try? Data(contentsOf: URL(fileURLWithPath: path.absoluteString))
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
                                            lineColor: UIColor.white,
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
                                    if self.hoursList.index(of: (depart.dateCompenents?.hour)!) == nil {
                                        self.hoursList.append((depart.dateCompenents?.hour)!)
                                    }
                                }
                                
                                if self.hoursList.isEmpty {
                                    SCLAlertView().showError("Pas de réseau", subTitle: "Nous ne pouvons charger la totalité des départs car vous n'avez pas télécharger les départs et vous n'êtes pas connecté à internet", closeButtonTitle: "OK").setDismissBlock({
                                          _ = self.navigationController?.popViewController(animated: true)
                                    })
                                }
                                else {
                                    self.actualHour = self.hoursList[0]
                                }
                            }
                            
                            self.departuresList = self.initialDeparturesList.filter({ (depart) -> Bool in
                                if depart.dateCompenents?.hour == self.actualHour {
                                    return true
                                }
                                return false
                            })
                        }
                        else {
                            SCLAlertView().showError("Pas de réseau", subTitle: "Nous ne pouvons charger la totalité des départs car vous n'avez pas télécharger les départs et vous n'êtes pas connecté à internet", closeButtonTitle: "OK").setDismissBlock({
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                        }
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
            }.main {
                self.hourPicker.reloadData()
                self.departuresCollectionView.reloadData()
        }
    }
}

extension SeeAllDeparturesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.departuresList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tousLesDepartsCell", for: indexPath) as! AllDeparturesCollectionViewCell
        
        let departure = self.departuresList[indexPath.row]
        let date = departure.dateCompenents?.date!
        
        cell.title.text = DateFormatter.localizedString(from: date!, dateStyle: .none, timeStyle: .short)
        cell.title.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 4, height: 50)
    }
}

extension SeeAllDeparturesViewController: AKPickerViewDataSource, AKPickerViewDelegate {
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return hoursList.count
    }
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return "\(hoursList[item])h"
    }
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        self.actualHour = hoursList[item]
        refresh()
    }
}
