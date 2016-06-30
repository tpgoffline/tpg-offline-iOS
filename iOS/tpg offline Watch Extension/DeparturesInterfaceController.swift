
//
//  DeparturesInterfaceController.swift
//  tpg offline
//
//  Created by Alice on 10/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON

class DeparturesInterfaceController: WKInterfaceController {
    
    var stop: Stop? = nil
    var departuresList: [Departures]! = []
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    @IBOutlet weak var departuresTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        loadingImage.setHidden(false)
        departuresTable.setHidden(true)
        stop = (context as! Stop)
        refreshDepartures()
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func refreshDepartures() {
        departuresList = []
        Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": stop!.stopCode])
            .responseJSON { response in
                if let data = response.result.value {
                    let departs = JSON(data)
                    for (_, subjson) in departs["departures"] {
                        if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                            self.departuresList.append(Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: UIColor.whiteColor(),
                                lineBackgroundColor: UIColor.whiteColor(),
                                
                                code: String(subjson["departureCode"].intValue ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                                ))
                        }
                        else {
                            self.departuresList.append(Departures(
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
                    }
                    self.refreshTable()
                }
                else {
                    let day: String!
                    
                    switch NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate()).weekday {
                    case 7:
                        day = "SAM"
                        break
                    case 1:
                        day = "DIM"
                        break
                    default:
                        day = "LUN"
                        break
                    }
                    
                    if let departuresString = AppValues.offlineDepartures[(self.stop?.stopCode)!] {
                        var json = JSON(data: departuresString.dataUsingEncoding(NSUTF8StringEncoding)!)
                        if json[day].string != nil {
                            json = JSON(data: json[day].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                            for (_, subjson) in json {
                                if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                                    self.departuresList.append(Departures(
                                        line: subjson["line"]["lineCode"].string!,
                                        direction: subjson["line"]["destinationName"].string!,
                                        destinationCode: subjson["line"]["destinationCode"].string!,
                                        lineColor: UIColor.whiteColor(),
                                        lineBackgroundColor: UIColor.whiteColor(),
                                        
                                        code: String(subjson["departureCode"].intValue ?? 0),
                                        leftTime: subjson["waitingTime"].string!,
                                        timestamp: subjson["timestamp"].string
                                        ))
                                }
                                else {
                                    self.departuresList.append(Departures(
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
                            }
                            self.departuresList = self.departuresList.filter({ (depart) -> Bool in
                                if depart.leftTime != "-1" {
                                    return true
                                }
                                return false
                            })
                            
                            self.departuresList.sortInPlace({ (depart1, depart2) -> Bool in
                                if Int(depart1.leftTime) < Int(depart2.leftTime) {
                                    return true
                                }
                                return false
                            })
                        }
                    }
                    
                }
                self.loadingImage.setHidden(true)
                self.departuresTable.setHidden(false)
        }
    }
    
    func refreshTable() {
        departuresTable.setNumberOfRows(self.departuresList.count, withRowType: "DeparturesRow")
        for index in 0..<departuresTable.numberOfRows {
            if let controller = departuresTable.rowControllerAtIndex(index) as? DeparturesRowController {
                controller.departure = departuresList[index]
            }
        }
    }
}
