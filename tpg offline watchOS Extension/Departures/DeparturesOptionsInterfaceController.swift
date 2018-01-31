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
            presentAllStops()
        default:
            return
        }
    }

    func presentAllStops() {
        presentTextInputController(withSuggestions: App.stops.map({ $0.name }), allowedInputMode: WKTextInputMode.plain, completion: { (resultO) in
            guard let result = resultO as? [String] else { return }
            if let stop = App.stops.filter({ $0.name.escaped == result[0].escaped })[safe: 0] {
                self.pushController(withName: "linesInterface", context: stop)
            } else if let stop = App.stops.filter({ $0.code.escaped == result[0].escaped })[safe: 0] {
                self.pushController(withName: "linesInterface", context: stop)
            } else {
                guard let stop = App.stops.filter({ $0.name.escaped.contains(result[0].escaped) })[safe: 0] else {
                    let tryAgainAction = WKAlertAction(title: "Try again".localized, style: .default, handler: {
                        self.presentAllStops()
                    })
                    let cancelAction = WKAlertAction(title: "Cancel".localized, style: .cancel, handler: {})
                    self.presentAlert(withTitle: "Stop not found", message: "We did not found the stop. Please try with another name.", preferredStyle: .alert, actions: [tryAgainAction, cancelAction])
                    return
                }

                let yesAction = WKAlertAction(title: "Yes".localized, style: .default, handler: {
                    self.pushController(withName: "linesInterface", context: stop)
                })
                let cancelAction = WKAlertAction(title: "Cancel".localized, style: .cancel, handler: {})
                self.presentAlert(withTitle: "Confirmation".localized, message: String(format: "Do you mean %@?".localized, stop.name), preferredStyle: WKAlertControllerStyle.alert, actions: [yesAction, cancelAction])
            }
        })
    }
}
