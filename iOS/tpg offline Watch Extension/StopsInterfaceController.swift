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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        refresh()
    }

    override func willActivate() {
        super.willActivate()
        
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func reloadButtonTaped(sender: AnyObject!) {
        refresh()
    }
    
    func refresh() {
        stopsTable.setNumberOfRows(AppValues.favoritesStops.count, withRowType: "StopsRow")
        var favortesStopsKeys = Array(AppValues.favoritesStops.keys)
        favortesStopsKeys.sortInPlace({ (string1, string2) -> Bool in
            let stringA = String((AppValues.favoritesStops[string1]?.title)! + (AppValues.favoritesStops[string1]?.subTitle)!)
            let stringB = String((AppValues.favoritesStops[string2]?.title)! + (AppValues.favoritesStops[string2]?.subTitle)!)
            if stringA.lowercaseString < stringB.lowercaseString {
                return true
            }
            return false
        })
        for index in 0..<stopsTable.numberOfRows {
            if let controller = stopsTable.rowControllerAtIndex(index) as? StopsRowController {
                controller.stop = AppValues.favoritesStops[favortesStopsKeys[index]]
            }
        }
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        pushControllerWithName("Departures", context: (stopsTable.rowControllerAtIndex(rowIndex) as! StopsRowController).stop)
    }
}
