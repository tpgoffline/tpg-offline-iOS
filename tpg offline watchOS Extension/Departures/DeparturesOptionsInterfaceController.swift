//
//  DeparturesOptionsInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 07/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Foundation

enum DeparturesOption {
    case nearestStops
    case favorites
    case allStops
}

class DeparturesOptionsInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!

    override init() {
        super.init()

        tableView.setNumberOfRows(3, withRowType: "optionRow")

        let rows = [BasicRow(icon: #imageLiteral(resourceName: "clock"), title: "Nearest Stops".localized),
                    BasicRow(icon: #imageLiteral(resourceName: "clock"), title: "Favorites".localized),
                    BasicRow(icon: #imageLiteral(resourceName: "clock"), title: "All Stops".localized)]

        for (index, row) in rows.enumerated() {
            guard let rowController = self.tableView.rowController(at: index) as? BasicRowController
                else { continue }
            rowController.row = row
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        switch rowIndex {
        case 0:
            pushController(withName: "stopsInterface", context: DeparturesOption.nearestStops)
        case 1:
            pushController(withName: "stopsInterface", context: DeparturesOption.favorites)
        case 2:
            pushController(withName: "stopsInterface", context: DeparturesOption.allStops)
        default:
            return
        }
    }
}
