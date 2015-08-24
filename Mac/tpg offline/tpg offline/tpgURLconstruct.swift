//
//  tpgURLconstruct.swift
//  tpg mac
//
//  Created by remy on 03/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import Cocoa

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
            if let _ = stopName.rangeOfString("[^a-zA-Z0-9-\'\\s]", options: .RegularExpressionSearch) {
                return ""
            }
            else {
                url += "&stopName="
                url += protegerURL(stopName)
            }
        }
        return url
    }
    
    func getPhysicalStops(stopName: String!) -> String {
        var url = "http://rtpi.data.tpg.ch/v1/GetPhysicalStops"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        if stopName != "" && stopName != nil {
            if let _ = stopName.rangeOfString("[^a-zA-Z0-9-\'\\s]", options: .RegularExpressionSearch) {
                return ""
            }
            else {
                url += "&stopName="
                url += protegerURL(stopName)
            }
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
        if let _ = stopCode.rangeOfString("[^a-zA-Z0-9-\'\\s]", options: .RegularExpressionSearch) {
            return ""
        }
        else {
            url += "&stopCode="
            url += protegerURL(stopCode)
        }
        return url
    }
    func getDisruptionsURL() -> String {
        var url = "http://rtpi.data.tpg.ch/v1/GetDisruptions"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        return url
    }
    func getLinesColorsURL() -> String {
        var url = "http://rtpi.data.tpg.ch/v1/GetLinesColors"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        return url
    }
    func protegerURL(url: String) -> String {
        let data = url.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let urlProtege = String(NSString(data: data!, encoding: NSASCIIStringEncoding)!)
        var chaine = ""
        for x in urlProtege.characters {
            switch x {
            case " ":
                chaine += "%20"
            case "&":
                chaine += ""
            case "=":
                chaine += ""
            default:
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
