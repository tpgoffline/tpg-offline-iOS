//
//  AppValues.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import ChameleonFramework
import Log

struct AppValues {
    static var stops: [String:Stop] = [:]
    static var favoritesStops: [String:Stop]!  = [:]
    static var fullNameFavoritesStops: [String]!  = []
	static var favoritesRoutes: [[Stop]]! = []
    static var stopCodeToStopItem: [String: String] = [:]
    static var primaryColor: UIColor! = UIColor.flatOrangeColor()
    static var secondaryColor: UIColor! = UIColor.flatOrangeColorDark()
    static var textColor: UIColor! = UIColor.whiteColor()
	static var premium: Bool! = false
    static var logger = Logger()
    static var stopsKeys: [String] = []
    static var linesBackgroundColor = [String:UIColor]()
    static var linesColor = [String:UIColor]()
    
    static func testTimeExecution(title: String!, block: () -> ()) {
        // Thanks to @kristopherjohnson (GitHub)
        let start = CACurrentMediaTime()
        block();
        let end = CACurrentMediaTime()
        logger.info("Execution time of \(title) : \(end - start)s")
    }
}