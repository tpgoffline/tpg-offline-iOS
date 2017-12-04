//
//  LinesInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 07/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Alamofire

class LinesInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!

    var stop: Stop? = nil {
        didSet {
            refreshDepartures()
        }
    }

    var departures: DeparturesGroup? = nil {
        didSet {
            guard let departures = departures else {
                tableView.setNumberOfRows(0, withRowType: "linesRow")
                return
            }
            tableView.setNumberOfRows(departures.lines.count, withRowType: "linesRow")
            for (index, line) in departures.lines.enumerated() {
                guard let rowController = self.tableView.rowController(at: index) as? BasicRowController
                    else { continue }
                rowController.row = BasicRow(icon: nil, title: String(format: "Line %@".localized, line))
                rowController.group.setBackgroundColor(App.color(for: line))
                rowController.titleLabel.setTextColor(App.color(for: line).contrast)
            }
            loadingImage.setImage(nil)
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let option = context as? Stop else {
            print("Context is not in a valid format")
            return
        }
        self.stop = option
        self.setTitle(self.stop?.code)
        self.addMenuItem(with: WKMenuItemIcon.resume, title: "Reload".localized, action: #selector(self.refreshDepartures))
    }

    @objc func refreshDepartures() {
        guard let stop = self.stop else { return }
        self.departures = nil
        loadingImage.setImageNamed("loading-")
        loadingImage.startAnimatingWithImages(in: NSRange(location: 0, length: 60), duration: 2, repeatCount: -1)
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json",
                          method: .get,
                          parameters: ["key": API.tpg,
                                       "stopCode": stop.code])
            .responseData { (response) in
                if let data = response.result.value {
                    var options = DeparturesOptions()
                    options.networkStatus = .online
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.userInfo = [ DeparturesOptions.key: options ]

                    do {
                        let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
                        self.departures = json
                        //self.requestStatus = .ok
                    } catch {
                        print("No Internet")
                        return
                    }

                    if self.departures?.lines.count == 0 {
                        //self.requestStatus = .noResults
                    }
                } else {
                    //self.loadOfflineDepartures()
                }
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let line = departures?.lines[rowIndex] else { return }
        guard let departures = self.departures else { return }
        pushController(withName: "departuresInterface", context: [departures, line])
    }
}
