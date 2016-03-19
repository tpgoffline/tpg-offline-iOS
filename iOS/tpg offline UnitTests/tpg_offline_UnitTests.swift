//
//  tpg_offline_UnitTests.swift
//  tpg offline UnitTests
//
//  Created by Alice on 17/03/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import XCTest
import SwiftyJSON
import CoreLocation

class tpg_offline_UnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            if let dataArrets = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("arrets", ofType: "json")!) {
                let arrets = JSON(data: dataArrets)
                
                
                for (_, subJson) in arrets["stops"] {
                    AppValues.arrets[subJson["stopName"].string!] = Arret(
                        nomComplet: subJson["stopName"].string!,
                        titre: subJson["titleName"].string!,
                        sousTitre: subJson["subTitleName"].string!,
                        stopCode: subJson["stopCode"].string!,
                        location: CLLocation(
                            latitude: subJson["locationX"].double!,
                            longitude: subJson["locationY"].double!
                        ),
                        idTransportAPI: subJson["idTransportAPI"].string!
                    )
                }
            }
            
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPerformanceExample1() {
        // This is an example of a performance test case.
        self.measureBlock {
            if let dataArrets = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("arrets2", ofType: "json")!) {
                let arrets = JSON(data: dataArrets)
                
                
                for (_, subJson) in arrets["stops"] {
                    AppValues.arrets[subJson["stopName"].string!] = Arret(
                        nomComplet: subJson["stopName"].string!,
                        titre: subJson["titleName"].string!,
                        sousTitre: subJson["subTitleName"].string!,
                        stopCode: subJson["stopCode"].string!,
                        location: CLLocation(
                            latitude: subJson["locationX"].double!,
                            longitude: subJson["locationY"].double!
                        ),
                        idTransportAPI: subJson["idTransportAPI"].string!
                    )
                }
            }
            // Put the code you want to measure the time of here.
        }
    }
    
}
