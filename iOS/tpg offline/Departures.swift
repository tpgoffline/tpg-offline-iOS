//
//  Departures.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

internal class Departures {
    var line: String!
    var direction: String!
    var destinationCode: String!
    var lineColor: UIColor!
    var lineBackgroundColor: UIColor!
    var code: String!
    var leftTime: String!
    var timestamp: String!
    var dateCompenents: NSDateComponents?
    
    init(line: String!, direction: String!, destinationCode: String, lineColor: UIColor!, lineBackgroundColor: UIColor!, code: String!, leftTime: String?, timestamp: String!) {
        self.line = line
        self.direction = direction
        self.destinationCode = destinationCode
        self.lineColor = lineColor
        self.lineBackgroundColor = lineBackgroundColor
        self.code = code
        self.leftTime = leftTime
        self.timestamp = timestamp
    }
    
    func calculerTempsRestant() {
        if timestamp == nil {
            self.leftTime = "-1"
        }
        else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            let time = dateFormatter.dateFromString(timestamp)
            let tempsTimestamp: NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: time!)
            
            let now: NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate())
            tempsTimestamp.year = now.year
            tempsTimestamp.month = now.month
            tempsTimestamp.day = now.day
            
            dateCompenents = tempsTimestamp
            
            if NSCalendar.currentCalendar().dateFromComponents(tempsTimestamp)!.compare(NSDate()) == .OrderedAscending {
                self.leftTime = "-1"
            }
            else {
                self.leftTime = String(Int(NSCalendar.currentCalendar().dateFromComponents(tempsTimestamp)!.timeIntervalSinceNow / 60))
            }
        }
    }
}