//
//  RouteResultsInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 14/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class RouteResultsInterfaceController: WKInterfaceController {

    var route: Route? {
        didSet {
            self.loadRoutes()
        }
    }

    var results: RouteResults? = nil {
        didSet {
            self.loadTable()
        }
    }

    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard let route = context as? Route else { return }
        self.route = route
        self.setTitle("\(route.from?.code ?? "") - \(route.to?.code ?? "")")
    }

    func loadRoutes() {
        self.results = nil
        guard let route = self.route else { return }
        loadingImage.setImageNamed("loading-")
        loadingImage.startAnimatingWithImages(in: NSRange(location: 0, length: 60), duration: 2, repeatCount: -1)
        var parameters: [String: Any] = [:]
        parameters["from"] = route.from?.sbbId
        parameters["to"] = route.to?.sbbId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        parameters["date"] = dateFormatter.string(from: route.date)
        dateFormatter.dateFormat = "HH:mm"
        parameters["time"] = dateFormatter.string(from: route.date)
        parameters["isArrivalTime"] = String(describing: route.arrivalTime.hashValue)
        parameters["fields"] = [
            "connections/duration",
            "connections/from/station/id",
            "connections/from/station/name",
            "connections/from/station/coordinate",
            "connections/from/departureTimestamp",
            "connections/to/station/id",
            "connections/to/station/name",
            "connections/to/station/coordinate",
            "connections/to/arrivalTimestamp",
            "connections/sections/walk",
            "connections/sections/journey/number",
            "connections/sections/journey/operator",
            "connections/sections/journey/category",
            "connections/sections/journey/to",
            "connections/sections/journey/passList",
            "connections/sections/departure/station/name",
            "connections/sections/departure/station/id",
            "connections/sections/departure/station/coordinate",
            "connections/sections/departure/departureTimestamp",
            "connections/sections/arrival/station/name",
            "connections/sections/arrival/station/id",
            "connections/sections/arrival/station/coordinate",
            "connections/sections/arrival/arrivalTimestamp"
        ]
        parameters["limit"] = 6

        Alamofire.request("https://transport.opendata.ch/v1/connections", method: .get, parameters: parameters).responseData { (response) in
            if let data = response.result.value {
                do {
                    let results = try JSONDecoder().decode(RouteResults.self, from: data)
                    self.results = results
                } catch let error as NSError {
                    dump(error)
                    //self.requestStatus = .error
                }
            } else {
                //self.requestStatus = .error
            }
        }
    }

    func loadTable() {
        self.tableView.setNumberOfRows(self.results?.connections.count ?? 0, withRowType: "connectionRow")
        guard let results = self.results else { return }
        for (index, result) in results.connections.enumerated() {
            guard let rowController = self.tableView.rowController(at: index) as?
                RoutesRowController else { continue }
            rowController.connection = result
        }
        self.loadingImage.setImage(nil)
    }

    override func willActivate() {
        super.willActivate()
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let results = self.results else { return }
        self.pushController(withName: "routeResultsDetailController",
                            context: results.connections[rowIndex])
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
}
