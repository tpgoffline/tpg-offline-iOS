//
//  NSUserDefaultsExtension.swift
//  i-de
//
//  Created by Bernex.net on 17.09.15.
//  Copyright © 2015 DCF. All rights reserved.
//

import UIKit

extension NSUserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
    func stringArrayForKeySwift(key: String) -> [String]? {
        var stringArray: [String]?
        if let stringData = dataForKey(key) {
            stringArray = NSKeyedUnarchiver.unarchiveObjectWithData(stringData) as? [String]
        }
        return stringArray
    }
    
    func setStringArraySwift(string: [String]?, forKey key: String) {
        var stringData: NSData?
        if let string = string {
            stringData = NSKeyedArchiver.archivedDataWithRootObject(string)
        }
        setObject(stringData, forKey: key)
    }
    func stringDictionnaryForKeySwift(key: String) -> [String: String]? {
        var stringArray: [String: String]?
        if let stringData = dataForKey(key) {
            stringArray = NSKeyedUnarchiver.unarchiveObjectWithData(stringData) as? [String: String]
        }
        return stringArray
    }
    
    func setStringDictionnarySwift(string: [String: String]?, forKey key: String) {
        var stringData: NSData?
        if let string = string {
            stringData = NSKeyedArchiver.archivedDataWithRootObject(string)
        }
        setObject(stringData, forKey: key)
    }
    
    func arretArrayForKey(key: String) -> [Arret]? {
        var arrayValue: [Arret]?
        if let arrayData = dataForKey(key) {
            arrayValue = NSKeyedUnarchiver.unarchiveObjectWithData(arrayData) as? [Arret]
        }
        return arrayValue
    }
    
    func setArretArray(array: [Arret]?, forKey key: String) {
        var arrayData: NSData?
        if let array = array {
            arrayData = NSKeyedArchiver.archivedDataWithRootObject(array)
        }
        setObject(arrayData, forKey: key)
    }
}