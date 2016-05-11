//
//  AppValues.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework
import Log

struct AppValues {
    static var arrets: [String: Arret] = [:]
    static var arretsFavoris: [String: Arret]!  = [:]
    static var nomCompletsFavoris: [String]!  = []
	static var favorisItineraires: [[Arret]]! = []
    static var stopCodeToArret: [String: String] = [:]	
    static var primaryColor: UIColor! = UIColor.flatOrangeColor()
    static var secondaryColor: UIColor! = UIColor.flatOrangeColorDark()
    static var textColor: UIColor! = UIColor.whiteColor()
	static var premium: Bool! = false
    static var logger = Logger()
    static var arretsKeys: [String] = []
    static var listeBackgroundColor = [String:UIColor]()
    static var listeColor = [String:UIColor]()
    
    static func testTimeExecution(title: String!, block: () -> ()) {
        // Thanks to @kristopherjohnson (GitHub)
        let start = CACurrentMediaTime()
        block();
        let end = CACurrentMediaTime()
        logger.info("Execution time of \(title) : \(end - start)s")
    }
}
