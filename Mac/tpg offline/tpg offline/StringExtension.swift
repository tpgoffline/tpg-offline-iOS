//
//  StringExtension.swift
//  Mon tpg
//
//  Created by remy on 24/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import Cocoa

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}
