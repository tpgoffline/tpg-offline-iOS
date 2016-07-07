//
//  tpg_offline_UITests.swift
//  tpg offline UITests
//
//  Created by remy on 28/02/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import XCTest
@testable import tpg_offline

class tpg_offline_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		let app = XCUIApplication()
		app.launchArguments = ["-donotask"]
		setupSnapshot(app)
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStops() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        
        XCTAssert(app.tables.cells.count != 0)
    }
    
    func testDepartures() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        app.tables.cells.elementBoundByIndex(0).tap()
        
        XCTAssert(app.tables.cells.count != 0)
    }
    
    func testFavorites() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        app.tables.cells.elementBoundByIndex(0).tap()
        
        let button = app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(4)
        button.tap()
        button.tap()
        
    }
    
    func testRouteToStop() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        app.tables.cells.elementBoundByIndex(0).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(3).tap()
    }
    
    func testSeeAllDepartures() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        app.tables.cells.elementBoundByIndex(0).swipeLeft()
        app.tables.buttons.elementBoundByIndex(1).tap()
    }
    
    func testThermometer() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        app.tables.cells.elementBoundByIndex(0).tap()
    }
    
    func testDeparturesReminder() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(0).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        app.tables.cells.elementBoundByIndex(0).swipeLeft()
        app.tables.buttons.elementBoundByIndex(0).tap()

        app.buttons.elementBoundByIndex(0).tap()
    }
    
    func testIncidents() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(1).tap()
        
        XCTAssert(app.tables.cells.count != 0)
    }
    
    func testRoutes() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(2).tap()

        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(2).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()

        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(3).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        XCUIApplication().tables.buttons.elementBoundByIndex(0).tap()
        
        sleep(10)

        if app.tables.cells.count != 1 {
            app.tables.cells.elementBoundByIndex(0).tap()
        }
    }
    
    func testMaps() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(3).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        XCTAssert(app.images.elementBoundByIndex(0).exists)
    }
    
    func testSettings() {
        let app = XCUIApplication()
        app.tabBars.buttons.elementBoundByIndex(4).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(5).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(2).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(5).tap()
        
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        
        app.navigationBars.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
    }
}
