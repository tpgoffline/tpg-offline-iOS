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
    var dateCompenents: DateComponents?
    
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            let time = dateFormatter.date(from: timestamp)
            var tempsTimestamp: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time!)
            
            let now: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            tempsTimestamp.year = now.year
            tempsTimestamp.month = now.month
            tempsTimestamp.day = now.day
            tempsTimestamp.calendar = Calendar.current
            tempsTimestamp.timeZone = now.timeZone
            
            dateCompenents = tempsTimestamp
            
            if Calendar.current.date(from: tempsTimestamp)!.compare(Date()) == .orderedAscending {
                self.leftTime = "-1"
            }
            else {
                self.leftTime = String(Int(Calendar.current.date(from: tempsTimestamp)!.timeIntervalSinceNow / 60))
            }
        }
    }
    
    func describe() -> String {
        return "[line: \(line), direction: \(direction), destinationCode: \(destinationCode), lineColor: \(lineColor), lineBackgroundColor: \(lineBackgroundColor), code: \(code), leftTime: \(leftTime), timestamp: \(timestamp), dateCompenents: \(dateCompenents)]"
    }
}
