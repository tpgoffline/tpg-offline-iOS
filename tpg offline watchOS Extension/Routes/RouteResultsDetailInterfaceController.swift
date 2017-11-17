//
//  RouteResultsDetailInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 17/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Foundation

class RouteResultsDetailInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    var connection: RouteConnection? {
        didSet {
            self.loadTable()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard let connection = context as? RouteConnection else { return }
        self.connection = connection
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
    }

    func loadTable() {
        guard let connection = self.connection else { return }
        self.tableView.setNumberOfRows(connection.sections?.count ?? 0, withRowType: "routesResultDetailRow")
        guard let sections = connection.sections else { return }
        for (index, section) in sections.enumerated() {
            guard let rowController = self.tableView.rowController(at: index) as?
                RoutesResultDetailRowController else { continue }
            rowController.section = section
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

class RoutesResultDetailRowController: NSObject {
    @IBOutlet weak var lineLabel: WKInterfaceLabel!
    @IBOutlet weak var separator1: WKInterfaceSeparator!
    @IBOutlet weak var separator2: WKInterfaceSeparator!
    @IBOutlet weak var fromImage: WKInterfaceImage!
    @IBOutlet weak var fromStop: WKInterfaceLabel!
    @IBOutlet weak var fromHour: WKInterfaceLabel!
    @IBOutlet weak var toImage: WKInterfaceImage!
    @IBOutlet weak var toStop: WKInterfaceLabel!
    @IBOutlet weak var toHour: WKInterfaceLabel!
    @IBOutlet weak var group: WKInterfaceGroup!

    var section: RouteConnection.Sections? {
        didSet {
            guard let section = section else { return }

            let destinationName = App.stops.filter({$0.nameTransportAPI == section.journey?.to})[safe: 0]?.name
                ?? (section.journey?.to ?? "#?!")

            var color = UIColor.black

            self.lineLabel.setText(String(format: "Line %@ - %@".localized, "\(section.journey?.lineCode ?? "#?!".localized)", "\(destinationName)"))
            if section.journey?.compagny == "TPG" {
                color = App.color(for: section.journey?.lineCode ?? "")
            } else if section.journey?.compagny == "SBB" {
                self.lineLabel.setText(String(format: "SBB %@ - %@".localized, "\(section.journey?.lineCode ?? "#?!".localized)",
                    "\(destinationName)"))
                color = .red
            } else {
                color = .black
            }

            self.group.setBackgroundColor(color)
            self.lineLabel.setTextColor(color.contrast)
            self.fromStop.setTextColor(color.contrast)
            self.fromHour.setTextColor(color.contrast)
            self.toStop.setTextColor(color.contrast)
            self.toHour.setTextColor(color.contrast)
            self.separator1.setColor(color.contrast)
            self.separator2.setColor(color.contrast)
            self.fromImage.setImage(#imageLiteral(resourceName: "from").maskWith(color: color.contrast))
            self.toImage.setImage(#imageLiteral(resourceName: "to").maskWith(color: color.contrast))

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            fromStop.setText((App.stops.filter({$0.sbbId == section.departure.station.id})[safe: 0]?.name)
                ?? section.departure.station.name)
            fromHour.setText(dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(section.departure.departureTimestamp ?? 0))))
            toStop.setText((App.stops.filter({$0.sbbId == section.arrival.station.id})[safe: 0]?.name)
                ?? section.arrival.station.name)
            toHour.setText(dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(section.arrival.arrivalTimestamp ?? 0))))
        }
    }
}
