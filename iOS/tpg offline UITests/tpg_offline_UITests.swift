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
		setupSnapshot(app)
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
		snapshot("Departs")
		
		let tabBar = XCUIApplication().tabBars
		
		XCUIApplication().tables.staticTexts["31 Décembre"].tap()
		
		snapshot("31DC")
		
		var secondButton = tabBar.buttons.elementBoundByIndex(2)
		secondButton.tap()
		
		snapshot("Itineraires")
		
		secondButton = tabBar.buttons.elementBoundByIndex(3)
		secondButton.tap()
		
		snapshot("Plans")
		
		secondButton = tabBar.buttons.elementBoundByIndex(4)
		secondButton.tap()
		
		snapshot("Paramètres")
    }
	
}
