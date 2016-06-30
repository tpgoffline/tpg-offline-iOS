//
//  DeparturesRowController.swift
//  tpg offline
//
//  Created by Alice on 12/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchKit

class DeparturesRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var lineLabel: WKInterfaceLabel!
    @IBOutlet var directionLabel: WKInterfaceLabel!
    @IBOutlet var leftTimeLabel: WKInterfaceLabel!
    
    var departure: Departures? {
        didSet {
            if let departure = departure {
                separator.setColor(departure.lineBackgroundColor ?? UIColor.whiteColor())
                lineLabel.setText(departure.line)
                directionLabel.setText(departure.direction)
                
                if (departure.leftTime == "no more") {
                    let attrStr = NSAttributedString(string: "\u{f00d}", attributes: [NSFontAttributeName: UIFont(name: "FontAwesome", size: 16)!])
                    leftTimeLabel.setAttributedText(attrStr)
                }
                else if (departure.leftTime == "&gt;1h") {
                    leftTimeLabel.setText(">1h")
                }
                else if (departure.leftTime == "0") {
                    let attrStr = NSAttributedString(string: "\u{f207}", attributes: [NSFontAttributeName: UIFont(name: "FontAwesome", size: 16)!])
                    leftTimeLabel.setAttributedText(attrStr)
                }
                else {
                    leftTimeLabel.setText(departure.leftTime + "'")
                }
            }
        }
    }
}
