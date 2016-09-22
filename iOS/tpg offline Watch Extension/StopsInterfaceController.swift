//
//  InterfaceController.swift
//  tpg offline Watch Extension
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class StopsInterfaceController: WKInterfaceController {

    @IBOutlet weak var stopsTable: WKInterfaceTable!
    @IBOutlet weak var noFavoritesLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if AppValues.favoritesStops.count == 0 {
            noFavoritesLabel.setHidden(false)
            stopsTable.setHidden(true)
        }
        else {
            noFavoritesLabel.setHidden(true)
            stopsTable.setHidden(false)
            refresh()
        }
    }

    override func willActivate() {
        super.willActivate()
        
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func reloadButtonTaped(_ sender: AnyObject!) {
        if AppValues.favoritesStops.count == 0 {
            noFavoritesLabel.setHidden(false)
            stopsTable.setHidden(true)
        }
        else {
            noFavoritesLabel.setHidden(true)
            stopsTable.setHidden(false)
            refresh()
        }
    }
    
    func refresh() {
        stopsTable.setNumberOfRows(AppValues.favoritesStops.count, withRowType: "StopsRow")
        var favoritesStopsKeys = Array(AppValues.favoritesStops.keys)
        favoritesStopsKeys.sort { (string1, string2) -> Bool in
            let stringA = String((AppValues.favoritesStops[string1]?.title)! + (AppValues.favoritesStops[string1]?.subTitle)!)
            let stringB = String((AppValues.favoritesStops[string2]?.title)! + (AppValues.favoritesStops[string2]?.subTitle)!)
            if stringA!.lowercased() < (stringB!.lowercased()) {
                return true
            }
            return false
        }

        for index in 0..<stopsTable.numberOfRows {
            if let controller = stopsTable.rowController(at: index) as? StopsRowController {
                controller.stop = AppValues.favoritesStops[favoritesStopsKeys[index]]
            }
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "Departures", context: (stopsTable.rowController(at: rowIndex) as! StopsRowController).stop)
    }
}
