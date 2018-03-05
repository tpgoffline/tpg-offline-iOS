//
//  tpg_offline_UITests.swift
//  tpg offline UITests
//
//  Created by Rémy DA COSTA FARO on 04/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
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
        app.launchArguments.append("-reset")
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        XCUIApplication().terminate()
    }
    
//    func testOpenStop() {
//        let app = XCUIApplication()
//        app.tabBars.buttons.element(boundBy: 0).tap()
//        app.tables.staticTexts["31 Décembre"].tap()
//    }
//
//    func testDepartures() {
//        let app = XCUIApplication()
//        app.tabBars.buttons.element(boundBy: 0).tap()
//        app.tables.staticTexts["31 Décembre"].tap()
//
//        let navigationBar = XCUIApplication().navigationBars["31 Décembre"]
//        navigationBar.buttons["starEmpty"].tap()
//        navigationBar.buttons["star"].tap()
//
//        let pinmapnavbarButton = navigationBar.buttons["pinMapNavBar"]
//        pinmapnavbarButton.tap()
//        pinmapnavbarButton.tap()
//        navigationBar.buttons["reloadNavBar"].tap()
//    }
//
    func testScreenshot() {
        let app = XCUIApplication()
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(5)
        snapshot("stops")
        app.tables.staticTexts["31 Décembre"].tap()
        sleep(5)
        snapshot("departures")
        app.tabBars.buttons.element(boundBy: 4).tap()
        app.tables.staticTexts["Dark Mode".localized].tap()
        app.tabBars.buttons.element(boundBy: 0).tap()
        snapshot("departuresDarkMode")
        app.tabBars.buttons.element(boundBy: 4).tap()
        app.tables.staticTexts["Dark Mode".localized].tap()
        app.tabBars.buttons.element(boundBy: 0).tap()
        app.tables.cells.element(boundBy: 0).tap()
        sleep(10)
        snapshot("busRoute")
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(10)
        snapshot("disruptions")
        app.tabBars.buttons.element(boundBy: 2).tap()
        snapshot("routes")
        app.tabBars.buttons.element(boundBy: 3).tap()
        snapshot("maps")
        app.tables.staticTexts[String(format: "Line %@".localized, "14")].tap()
        snapshot("line")
        app.tabBars.buttons.element(boundBy: 4).tap()
        snapshot("settings")
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
