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
    let dns = "http://prod.ivtr-od.tpg.ch/v1/"
    let regexCorrect = "[^a-zA-Z0-9-\'\\sàâêëéèîïôûùüç]"
    
    init(cleAPI:String, typeFichier:TypeFichier=TypeFichier.XML) {
        self.cleAPI = cleAPI
        self.typeFichier = typeFichier
    }
    
    func getStopsURL(stopName: String!) -> String {
        var url = dns + "GetStops"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        if stopName != "" && stopName != nil {
            if let _ = stopName.rangeOfString(regexCorrect, options: .RegularExpressionSearch) {
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
        var url = dns + "GetPhysicalStops"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        if stopName != "" && stopName != nil {
            if let _ = stopName.rangeOfString(regexCorrect, options: .RegularExpressionSearch) {
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
        var url = dns + "GetNextDepartures"
        if typeFichier == .XML {
            url += ".xml"
        }
        else {
            url += ".json"
        }
        url += "?key="
        url += cleAPI
        if let _ = stopCode.rangeOfString(regexCorrect, options: .RegularExpressionSearch) {
            return ""
        }
        else {
            url += "&stopCode="
            url += protegerURL(stopCode)
        }
        return url
    }
    func getDisruptionsURL() -> String {
        var url = dns + "GetDisruptions"
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
        var url = dns + "GetLinesColors"
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
            case "à":
                chaine += "a"
            case "â":
                chaine += "a"
            case "ê":
                chaine += "e"
            case "é":
                chaine += "e"
            case "ë":
                chaine += "e"
            case "è":
                chaine += "e"
            case "î":
                chaine += "i"
            case "ï":
                chaine += "i"
            case "ô":
                chaine += "o"
            case "û":
                chaine += "u"
            case "ù":
                chaine += "u"
            case "ü":
                chaine += "u"
            case "ç":
                chaine += "c"
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
