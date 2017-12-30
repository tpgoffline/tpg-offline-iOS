//
//  LinesInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 07/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import Alamofire

protocol DeparturesDelegate: class {
    func departuresDidUpdate()
}

class DeparturesManager: NSObject {

    static let sharedManager = DeparturesManager()
    var departures: DeparturesGroup?
    var stop: Stop?

    fileprivate override init() {
        super.init()
    }

    private var departuresDelegate = [DeparturesDelegate]()

    func addDeparturesDelegate<T>(delegate: T) where T: DeparturesDelegate, T: Equatable {
        departuresDelegate.append(delegate)
    }

    func removeDeparturesDelegate<T>(delegate: T) where T: DeparturesDelegate, T: Equatable {
        for (index, departuresADelegate) in departuresDelegate.enumerated() {
            if let departureDelegate = departuresADelegate as? T, departureDelegate == delegate {
                departuresDelegate.remove(at: index)
                break
            }
        }
    }

    func refreshDepartures() {
        guard let stop = self.stop else { return }
        self.departures = nil
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
                    } catch {
                        print("No Internet")
                        return
                    }

                    if self.departures?.lines.count == 0 {
                        self.departures = nil
                    }
                } else {
                    self.departures = nil
                }
                DispatchQueue.main.async {
                    self.departuresDelegate.forEach { $0.departuresDidUpdate() }
                }
        }
    }
}

class LinesInterfaceController: WKInterfaceController, DeparturesDelegate {
    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    @IBOutlet weak var errorLabel: WKInterfaceLabel!

    var stop: Stop? = nil {
        didSet {
            refreshDepartures()
        }
    }

    var departures: DeparturesGroup? = nil {
        didSet {
            loadingImage.setImage(nil)
            guard let departures = departures else {
                self.errorLabel.setText("Sorry, we can't fetch new departures. Please, try again.".localized)
                tableView.setNumberOfRows(0, withRowType: "linesRow")
                return
            }
            self.errorLabel.setText("")
            tableView.setNumberOfRows(departures.lines.count, withRowType: "linesRow")
            for (index, line) in departures.lines.enumerated() {
                guard let rowController = self.tableView.rowController(at: index) as? BasicRowController
                    else { continue }
                rowController.row = BasicRow(icon: nil, title: String(format: "Line %@".localized, line))
                rowController.group.setBackgroundColor(App.color(for: line))
                rowController.titleLabel.setTextColor(App.color(for: line).contrast)
            }
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let option = context as? Stop else {
            print("Context is not in a valid format")
            return
        }
        DeparturesManager.sharedManager.addDeparturesDelegate(delegate: self)
        DeparturesManager.sharedManager.stop = option
        self.stop = option
        self.setTitle(self.stop?.code)
        self.addMenuItem(with: WKMenuItemIcon.resume, title: "Reload".localized, action: #selector(self.refreshDepartures))
        self.errorLabel.setText("".localized)
    }

    @objc func refreshDepartures() {
        self.departures = nil
        self.errorLabel.setText("".localized)
        loadingImage.setImageNamed("loading-")
        loadingImage.startAnimatingWithImages(in: NSRange(location: 0, length: 60), duration: 2, repeatCount: -1)
        DeparturesManager.sharedManager.refreshDepartures()
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let line = departures?.lines[rowIndex] else { return }
        guard let departures = self.departures else { return }
        pushController(withName: "departuresInterface", context: [departures, line])
    }

    func departuresDidUpdate() {
        self.departures = DeparturesManager.sharedManager.departures
    }

    deinit {
        DeparturesManager.sharedManager.removeDeparturesDelegate(delegate: self)
    }
}
