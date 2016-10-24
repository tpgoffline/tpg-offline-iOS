//
//  tpg_offline_UITests.swift
//  tpg offline UITests
//
//  Created by remy on 28/02/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import XCTest

class tpg_offline_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		let app = XCUIApplication()
		app.launchArguments = ["-donotask"]
		//setupSnapshot(app: app)
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStops() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        
        XCTAssert(app.tables.cells.count != 0)
    }
    
    func testDepartures() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        XCTAssert(app.tables.cells.count != 0)
    }
    
    func testFavorites() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        app.tables.cells.element(boundBy: 0).tap()
        
        let button = app.navigationBars.children(matching: .button).element(boundBy: 4)
        button.tap()
        button.tap()
        
    }
    
    func testRouteToStop() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        app.tables.cells.element(boundBy: 0).tap()
        app.navigationBars.children(matching: .button).element(boundBy: 3).tap()
    }
    
    func testSeeAllDepartures() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        app.tables.cells.element(boundBy: 0).swipeLeft()
        app.tables.buttons.element(boundBy: 1).tap()
    }
    
    func testThermometer() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        app.tables.cells.element(boundBy: 0).tap()
    }
    
    func testDeparturesReminder() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        app.tables.cells.element(boundBy: 0).swipeLeft()
        app.tables.buttons.element(boundBy: 0).tap()

        app.buttons.element(boundBy: 0).tap()
    }
    
    func testIncidents() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssert(app.tables.cells.count != 0)
    }
    
    func testRoutes() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 2).tap()

        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 1).tap()
        app.tables.children(matching: .cell).element(boundBy: 1).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 2).tap()
        
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()

        app.tables.children(matching: .cell).element(boundBy: 3).tap()
        
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()
        
        XCUIApplication().tables.buttons.element(boundBy: 0).tap()
        
        sleep(10)

        if app.tables.cells.count != 1 {
            app.tables.cells.element(boundBy: 0).tap()
        }
    }
    
    func testMaps() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 3).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        XCTAssert(app.images.element(boundBy: 0).exists)
    }
    
    func testSettings() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 4).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 1).tap()
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 1).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 1).tap()
        app.tables.children(matching: .cell).element(boundBy: 5).tap()
        
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 2).tap()
        
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()
        
        app.tables.children(matching: .cell).element(boundBy: 5).tap()
        
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 1).tap()
        
        app.navigationBars.children(matching: .button).element(boundBy: 0).tap()
    }
}
