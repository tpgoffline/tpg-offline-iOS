//
//  HomeInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 05/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var tableView: WKInterfaceTable!

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
  }

  override init() {
    super.init()

    DispatchQueue.main.async {
      guard App.loadStops() else {
        print("Can't load stops")
        return
      }
    }

    loadTableData()
  }

  func loadTableData() {

    let rows = [BasicRow(icon: #imageLiteral(resourceName: "clock"), title: Text.departures),
                BasicRow(icon: #imageLiteral(resourceName: "warning"), title: Text.disruptions),
                BasicRow(icon: #imageLiteral(resourceName: "routes"), title: Text.routes)]

    tableView.setNumberOfRows(rows.count, withRowType: "homeRow")

    for (index, row) in rows.enumerated() {
      guard let rowController =
        self.tableView.rowController(at: index) as? BasicRowController
        else { continue }
      rowController.row = row
    }
  }

  override func willActivate() {
    super.willActivate()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    switch rowIndex {
    case 0:
      pushController(withName: "departuresOptionsInterface", context: nil)
    case 1:
      pushController(withName: "disruptionInterface", context: nil)
    case 2:
      pushController(withName: "routesController", context: nil)
    default:
      print("No action for this rowIndex")
    }
  }
}

class BasicRowController: NSObject {
  @IBOutlet var iconImageView: WKInterfaceImage!
  @IBOutlet var titleLabel: WKInterfaceLabel!
  @IBOutlet var group: WKInterfaceGroup!

  var row: BasicRow! {
    didSet {
      if let icon = row.icon {
        self.iconImageView.setImage(icon.maskWith(color: .white))
      }
      self.titleLabel.setText(row.title)
    }
  }
}

struct BasicRow {
  let icon: UIImage?
  let title: String
}
