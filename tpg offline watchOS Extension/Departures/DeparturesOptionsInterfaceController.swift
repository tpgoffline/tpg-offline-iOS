//
//  DeparturesOptionsInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 07/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
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

    let rows = [BasicRow(icon: #imageLiteral(resourceName: "clock"), title: Text.nearestStops),
                BasicRow(icon: #imageLiteral(resourceName: "clock"), title: Text.favorites),
                BasicRow(icon: #imageLiteral(resourceName: "clock"), title: "All Stops".localized)]

    for (index, row) in rows.enumerated() {
      guard let rowController = self.tableView.rowController(at: index)
        as? BasicRowController else { continue }
      rowController.row = row
    }
  }

  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    switch rowIndex {
    case 0:
      pushController(withName: "stopsInterface",
                     context: DeparturesOption.nearestStops)
    case 1:
      pushController(withName: "stopsInterface",
                     context: DeparturesOption.favorites)
    case 2:
      presentAllStops()
    default:
      return
    }
  }

  func presentAllStops() {
    presentTextInputController(withSuggestions: App.stops.map({ $0.name }),
                               allowedInputMode: WKTextInputMode.plain,
                               completion: { (resultO) in
      guard let result = resultO as? [String] else { return }
      if let stop = App.stops.filter({
        $0.name.escaped == result[0].escaped
      })[safe: 0] {
        self.pushController(withName: "linesInterface", context: stop)
      } else if let stop = App.stops.filter({
        $0.code.escaped == result[0].escaped
      })[safe: 0] {
        self.pushController(withName: "linesInterface", context: stop)
      } else {
        guard let stop = App.stops.filter({
          $0.name.escaped.contains(result[0].escaped)
        })[safe: 0] else {
          let tryAgainAction = WKAlertAction(title: Text.tryAgain,
                                             style: .default,
                                             handler: {
            self.presentAllStops()
          })
          let cancelAction = WKAlertAction(title: Text.cancel,
                                           style: .cancel,
                                           handler: {})
          self.presentAlert(withTitle: Text.stopNotFound,
                            message: Text.stopNotFoundSubtitle,
                            preferredStyle: .alert,
                            actions: [tryAgainAction, cancelAction])
          return
        }

        let yesAction = WKAlertAction(title: Text.yes,
                                      style: .default,
                                      handler: {
          self.pushController(withName: "linesInterface", context: stop)
        })
        let cancelAction = WKAlertAction(title: Text.cancel,
                                         style: .cancel,
                                         handler: {})
        self.presentAlert(withTitle: Text.confirmation,
                          message: Text.doYouMean(stop.name),
                          preferredStyle: WKAlertControllerStyle.alert,
                          actions: [yesAction, cancelAction])
      }
    })
  }
}
