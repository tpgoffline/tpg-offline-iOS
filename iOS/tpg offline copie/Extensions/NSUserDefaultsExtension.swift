//
//  NSUserDefaultsExtension.swift
//  tpg offline
//
//  Created by Bernex.net on 17.09.15.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    func colorForKey(_ key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(_ color: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }
    func stringArrayForKeySwift(_ key: String) -> [String]? {
        var stringArray: [String]?
        if let stringData = data(forKey: key) {
            stringArray = NSKeyedUnarchiver.unarchiveObject(with: stringData) as? [String]
        }
        return stringArray
    }
    
    func setStringArraySwift(_ string: [String]?, forKey key: String) {
        var stringData: Data?
        if let string = string {
            stringData = NSKeyedArchiver.archivedData(withRootObject: string)
        }
        set(stringData, forKey: key)
    }
    func stringDictionnaryForKeySwift(_ key: String) -> [String: String]? {
        var stringArray: [String: String]?
        if let stringData = data(forKey: key) {
            stringArray = NSKeyedUnarchiver.unarchiveObject(with: stringData) as? [String: String]
        }
        return stringArray
    }
    
    func setStringDictionnarySwift(_ string: [String: String]?, forKey key: String) {
        var stringData: Data?
        if let string = string {
            stringData = NSKeyedArchiver.archivedData(withRootObject: string)
        }
        set(stringData, forKey: key)
    }
    
    func arretArrayForKey(_ key: String) -> [Stop]? {
        var arrayValue: [Stop]?
        if let arrayData = data(forKey: key) {
            arrayValue = NSKeyedUnarchiver.unarchiveObject(with: arrayData) as? [Stop]
        }
        return arrayValue
    }
    
    func setArretArray(_ array: [Stop]?, forKey key: String) {
        var arrayData: Data?
        if let array = array {
            arrayData = NSKeyedArchiver.archivedData(withRootObject: array)
        }
        set(arrayData, forKey: key)
    }
}
