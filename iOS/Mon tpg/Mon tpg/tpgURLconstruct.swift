//
//  tpgURLconstruct.swift
//  tpg mac
//
//  Created by remy on 03/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import UIKit

enum TypeFichier: String {
    case XML = "XML"
    case JSON = "JSON"
}

class tpgURLconstruct {
    var cleAPI = ""
    var typeFichier = TypeFichier.XML
    
    init(cleAPI:String, typeFichier:TypeFichier=TypeFichier.XML) {
        self.cleAPI = cleAPI
        self.typeFichier = typeFichier
    }
    
    func getStopsURL(stopName: String!) -> String {
        var url = "http://rtpi.data.tpg.ch/v1/GetStops"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        if stopName != "" && stopName != nil {
            url += "&stopName="
            url += protegerURL(stopName)
        }
        return url
    }
    
    func getNextDeparturesURL(stopCode: String) -> String {
        var url = "http://rtpi.data.tpg.ch/v1/GetNextDepartures"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        url += "&stopCode="
        url += protegerURL(stopCode)
        return url
    }
    func protegerURL(url: String) -> String {
        let data = url.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let urlProtege = String(NSString(data: data!, encoding: NSASCIIStringEncoding)!)
        var chaine = ""
        for x in urlProtege.characters {
            if x == " " {
                chaine += "%20"
            }
            else {
                chaine += String(x)
            }
        }
        return chaine
    }
    func getLocalLaconnexXMLURL() -> NSURL! {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("laconnex", ofType: "xml")!)
        return url
    }
}
