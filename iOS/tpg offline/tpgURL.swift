//
//  tpgURL.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 05/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

class tpgURL {
    let cleAPI = "d95be980-0830-11e5-a039-0002a5d5c51b"
    let dns = "http://prod.ivtr-od.tpg.ch/v1/"
    
    init() {
    }
    
    func getAllStops() -> JSON? {
        if let dataArrets = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("arrets", ofType: "json")!) {
            let arrets = JSON(data: dataArrets)
            return arrets
        }
        else {
            return nil
        }
    }
    
    func getDisruptions() -> JSON? {
        var url = dns + "GetDisruptions.json"
        url += "?key=" + cleAPI
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            let disruptions = JSON(data: data)
            return disruptions
        }
        else {
            return nil
        }
    }
}
