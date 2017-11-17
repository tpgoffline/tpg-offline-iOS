//
//  DeparturesInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 08/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Foundation

class DeparturesInterfaceController: WKInterfaceController {

    var departures: DeparturesGroup? = nil {
        didSet {
            guard let a = self.departures else { return }
            let departures = a.departures.filter({ $0.line.code == self.line })
            tableView.setNumberOfRows(departures.count, withRowType: "departureCell")

            for (index, departure) in departures.enumerated() {
                guard let rowController = self.tableView.rowController(at: index) as? DepartureRowController
                    else { continue }
                rowController.departure = departure
            }
        }
    }

    var line: String = ""

    @IBOutlet weak var tableView: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard let option = context as? [Any] else {
            print("Context is not in a valid format")
            return
        }
        guard let departures = option[0] as? DeparturesGroup else {
            print("Context is not in a valid format")
            return
        }
        guard let line = option[1] as? String else {
            print("Context is not in a valid format")
            return
        }
        self.line = line
        self.departures = departures
        self.setTitle(String(format: "Line %@".localized, self.line))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

class DepartureRowController: NSObject {
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var leftTimeLabel: WKInterfaceLabel!

    private var canBeSelected: Bool = true

    var departure: Departure! {
        didSet {
            self.destinationLabel.setText(departure.line.destination)
            switch departure.leftTime {
            case "&gt;1h":
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                let time = dateFormatter.date(from: departure.timestamp)
                if let time = time {
                    self.leftTimeLabel.setText(DateFormatter.localizedString(
                        from: time,
                        dateStyle: DateFormatter.Style.none,
                        timeStyle: DateFormatter.Style.short))
                } else {
                    self.leftTimeLabel.setText("?")
                }
            case "no more":
                self.leftTimeLabel.setText("X")
                self.canBeSelected = false
            default:
                leftTimeLabel.setText("\(departure.leftTime.time)'")
            }
        }
    }
}
