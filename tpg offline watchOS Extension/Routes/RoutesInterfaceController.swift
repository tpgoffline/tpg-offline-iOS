//
//  RoutesInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 14/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Foundation

class RoutesInterfaceController: WKInterfaceController, AppDataChangedDelegate {

    @IBOutlet weak var tableView: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        self.setTitle("Routes".localized)
        self.loadTable()
        WatchSessionManager.sharedManager.addAppDataChangedDelegate(delegate: self)
    }

    func loadTable() {
        tableView.setNumberOfRows(App.favoritesRoutes.count, withRowType: "routesRow")
        for (index, route) in App.favoritesRoutes.enumerated() {
            guard let rowController = self.tableView.rowController(at: index) as?
                RoutesRowController else { continue }
            rowController.route = route
        }
    }

    func appDataDidUpdate() {
        self.loadTable()
    }

    override func didDeactivate() {
        WatchSessionManager.sharedManager.removeAppDataChangedDelegate(delegate: self)
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let route = App.favoritesRoutes[safe: rowIndex] else { return }
        pushController(withName: "routeResultsController", context: route)
    }
}

class RoutesRowController: NSObject {
    @IBOutlet weak var firstIcon: WKInterfaceImage!
    @IBOutlet weak var firstLabel: WKInterfaceLabel!
    @IBOutlet weak var secondIcon: WKInterfaceImage!
    @IBOutlet weak var secondLabel: WKInterfaceLabel!

    var route: Route? {
        didSet {
            guard let route = self.route else { return }
            firstIcon.setImage(#imageLiteral(resourceName: "from").maskWith(color: .white))
            secondIcon.setImage(#imageLiteral(resourceName: "to").maskWith(color: .white))
            firstLabel.setText(route.from?.name ?? "")
            secondLabel.setText(route.to?.name ?? "")
        }
    }

    var connection: RouteConnection? {
        didSet {
            guard let connection = self.connection else { return }
            firstIcon.setImage(#imageLiteral(resourceName: "from").maskWith(color: .white))
            secondIcon.setImage(#imageLiteral(resourceName: "to").maskWith(color: .white))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            firstLabel.setText(dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(connection.from.departureTimestamp ?? 0))))
            secondLabel.setText(dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(connection.to.arrivalTimestamp ?? 0))))
        }
    }
}
