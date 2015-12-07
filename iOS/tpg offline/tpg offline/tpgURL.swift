//
//  tpgURL.swift
//  tpg offline
//
//  Created by Alice on 05/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import CoreLocation

enum typesDonnes: String {
    case XML = "xml"
    case JSON = "json"
}

class tpgURL {
    let cleAPI = "d95be980-0830-11e5-a039-0002a5d5c51b"
    let dns = "http://prod.ivtr-od.tpg.ch/v1/"
    let typeDonnes = typesDonnes.JSON
    
    init() {
    }
    
    func getAllStops() -> NSData? {
        return NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("arrets", ofType: "json")!)!
    }
    
    func getStopsbyCode(stopCode: String) -> NSData? {
        var url = dns + "GetStops."
        url += typeDonnes.rawValue
        url += "?key=" + cleAPI
        url += "&stopCode=" + stopCode
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            return data
        }
        else {
            return nil
        }
    }
    
    func getStopsbyName(stopName: String) -> NSData? {
        var url = dns + "GetStops."
        url += typeDonnes.rawValue
        url += "?key=" + cleAPI
        url += "&stopName=" + stopName
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            return data
        }
        else {
            return nil
        }
    }
    
    func getStopsbyLine(line: String) -> NSData? {
        var url = dns + "GetStops."
        url += typeDonnes.rawValue
        url += "?key=" + cleAPI
        url += "&line=" + line
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            return data
        }
        else {
            return nil
        }
    }
    
    func getStopsbyLocation(location: CLLocation) -> NSData? {
        var url = dns + "GetStops."
        url += typeDonnes.rawValue
        url += "?key=" + cleAPI
        url += "&latitude=" + String(location.coordinate.latitude)
        url += "&longitude=" + String(location.coordinate.longitude)
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            return data
        }
        else {
            return nil
        }
    }
}
