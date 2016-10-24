//
//  Stop.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import CoreLocation

internal class Stop: NSObject, NSCoding {
    var fullName: String!
    var title: String!
    var subTitle: String!
    var stopCode: String!
    var location: CLLocation!
    var distance: Double?
    var transportAPIiD: String!
    var connections: [String]!
	
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()
        fullName = decoder.decodeObject(forKey: "fullName") as! String
        title = decoder.decodeObject(forKey: "title") as! String
        subTitle = decoder.decodeObject(forKey: "subTitle") as! String
        stopCode = decoder.decodeObject(forKey: "stopCode") as! String
        transportAPIiD = decoder.decodeObject(forKey: "transportAPIiD") as! String
        location = decoder.decodeObject(forKey: "location") as! CLLocation
        connections = decoder.decodeObject(forKey: "connections") as? [String] ?? []
    }
    convenience init(fullName: String, title: String, subTitle: String, stopCode: String, location: CLLocation, transportAPIiD: String, connections: [String]) {
        self.init()
        self.fullName = fullName
        self.title = title
        self.subTitle = subTitle
        self.stopCode = stopCode
        self.location = location
        self.transportAPIiD = transportAPIiD
        self.connections = connections
    }

    func encode(with coder: NSCoder) {
        if let fullName = fullName { coder.encode(fullName, forKey: "fullName") }
        if let title = title { coder.encode(title, forKey: "title") }
        if let subTitle = subTitle { coder.encode(subTitle, forKey: "subTitle") }
        if let stopCode = stopCode { coder.encode(stopCode, forKey: "stopCode") }
        if let location = location { coder.encode(location, forKey: "location") }
        if let transportAPIiD = transportAPIiD { coder.encode(transportAPIiD, forKey: "transportAPIiD") }
        if let connections = connections { coder.encode(connections, forKey: "connections") }
    }
    
    init(dictionnary: [String:Any]) {
        fullName = dictionnary["fullName"] as? String ?? ""
        title = dictionnary["title"] as? String ?? ""
        subTitle = dictionnary["subTitle"] as? String ?? ""
        stopCode = dictionnary["stopCode"] as? String ?? ""
        location = dictionnary["location"] as? CLLocation ?? CLLocation(latitude: 46.204705, longitude: 6.143060)
        transportAPIiD = dictionnary["transportAPIiD"] as? String ?? ""
        connections = dictionnary["connections"] as? [String] ?? []
    }
    
    func toDictionnary() -> [String:Any] {
        let attributes = [
            "fullName": fullName,
            "title": title,
            "subTitle": subTitle,
            "stopCode": stopCode,
            "transportAPIid": transportAPIiD,
            "location": location,
            "connections": connections
        ] as [String : Any]
        return attributes
    }
}
