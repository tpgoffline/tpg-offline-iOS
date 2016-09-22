//
//  StopsRowController.swift
//  tpg offline
//
//  Created by Alice on 09/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchKit

class StopsRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    //@IBOutlet var typeImage: WKInterfaceImage!
    @IBOutlet var stopTitleLabel: WKInterfaceLabel!
    @IBOutlet var stopSubTitleLabel: WKInterfaceLabel!
    
    var stop: Stop? {
        didSet {
            if let stop = stop {
                //typeImage.setImage(UIImage(named: "Star"))
                stopTitleLabel.setText(stop.title)
                stopSubTitleLabel.setText(stop.subTitle)
                separator.setColor(UIColor.orange)
            }
        }
    }
}
