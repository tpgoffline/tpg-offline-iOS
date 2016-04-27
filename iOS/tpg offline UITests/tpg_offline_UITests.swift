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
		app.launchArguments = ["-donotask", "-premium", "-takeScreenshot"]
		setupSnapshot(app)
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func takeScreenshot() {
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let paramTresButton = tabBarsQuery.buttons["Paramètres"]
        paramTresButton.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Thèmes"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts["Défaut"].tap()
        tabBarsQuery.buttons["Départs"].tap()
        
        snapshot("Arrets")
        
        tablesQuery.staticTexts["31 Décembre"].tap()
        
        snapshot("Departs")
        
        tabBarsQuery.buttons["Incidents"].tap()
        
        snapshot("Incidents")
        
        paramTresButton.tap()
        collectionViewsQuery.staticTexts["Inversé"].tap()
        tabBarsQuery.buttons["Itinéraires"].tap()
        tablesQuery.staticTexts["Départ"].tap()
        tablesQuery.staticTexts["31 Décembre"].tap()
        
        app.navigationBars["tpg_offline.tpgArretSelectionTableView"].buttons["Itinéraires"].tap()
        app.navigationBars["Itinéraires"].childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        tablesQuery.staticTexts["Arrivée"].tap()
        tablesQuery.staticTexts["ZIPLO"].tap()
        tablesQuery.buttons["Rechercher"].tap()
        app.navigationBars.containingType(.Button, identifier:"Itinéraires").childrenMatchingType(.Button).elementBoundByIndex(2).tap()
        app.navigationBars.matchingIdentifier("tpg_offline.ListeItinerairesTableView").buttons["Itinéraires"].tap()
        
        snapshot("Itinéraires")
        
        tabBarsQuery.buttons["Plans"].tap()
        
        snapshot("Plans")
        
        paramTresButton.tap()
        app.collectionViews.staticTexts["Nuit"].tap()
        paramTresButton.tap()
        
        snapshot("Paramètres")
    }
    
    
}
