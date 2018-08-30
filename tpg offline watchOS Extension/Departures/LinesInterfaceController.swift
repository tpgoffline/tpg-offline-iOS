//
//  LinesInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 07/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import WatchKit
import Alamofire

protocol DeparturesDelegate: class {
  func departuresDidUpdate()
}

class DeparturesManager: NSObject {

  static let shared = DeparturesManager()
  var departures: DeparturesGroup? {
    didSet {
      DispatchQueue.main.async {
        self.departuresDelegate.forEach { $0.departuresDidUpdate() }
      }
    }
  }
  var status = RequestStatus.noResults {
    didSet {
      DispatchQueue.main.async {
        self.departuresDelegate.forEach { $0.departuresDidUpdate() }
      }
    }
  }

  var stop: Stop?

  fileprivate override init() {
    super.init()
  }

  private var departuresDelegate = [DeparturesDelegate]()

  func addDeparturesDelegate<T>(delegate: T) where
    T: DeparturesDelegate, T: Equatable {
    departuresDelegate.append(delegate)
  }

  func removeDeparturesDelegate<T>(delegate: T) where
    T: DeparturesDelegate, T: Equatable {
    for (index, departuresADelegate) in departuresDelegate.enumerated() {
      if let departureDelegate = departuresADelegate as? T,
        departureDelegate == delegate {
        departuresDelegate.remove(at: index)
        break
      }
    }
  }

  func refreshDepartures() {
    self.status = .loading
    guard let stop = self.stop else {
      self.status = .error
      return
    }
    self.departures = nil
    Alamofire.request(URL.departures(with: stop.code), method: .get)
      .responseData { (response) in
        if let data = response.result.value {
          var options = DeparturesOptions()
          options.networkStatus = .online
          let jsonDecoder = JSONDecoder()
          jsonDecoder.userInfo = [ DeparturesOptions.key: options ]

          do {
            let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
            self.departures = json
            self.status = .ok
          } catch {
            print("No Internet")
            return
          }

          if self.departures?.lines.count == 0 {
            self.departures = nil
            self.status = .noResults
          }
        } else {
          self.departures = nil
          self.status = .error
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
        self.errorLabel.setText("")
        if DeparturesManager.shared.status == .error {
          self.errorLabel.setText(Text.errorNoInternet)
        } else if DeparturesManager.shared.status == .loading {
          loadingImage.setImageNamed("loading-")
          loadingImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                            length: 60),
                                                duration: 2,
                                                repeatCount: -1)
        }
        tableView.setNumberOfRows(0, withRowType: "linesRow")
        return
      }
      self.errorLabel.setText("")
      tableView.setNumberOfRows(departures.lines.count, withRowType: "linesRow")
      for (index, line) in departures.lines.enumerated() {
        guard let rowController = self.tableView.rowController(at: index)
          as? BasicRowController else { continue }
        rowController.row = BasicRow(icon: nil, title: Text.line(line))
        rowController.group.setBackgroundColor(LineColorManager.color(for: line,
                                                         operator: .tpg))
        rowController.titleLabel.setTextColor(LineColorManager.color(for: line,
                                                        operator: .tpg).contrast)
      }
    }
  }

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    guard let option = context as? Stop else {
      print("Context is not in a valid format")
      return
    }
    DeparturesManager.shared.addDeparturesDelegate(delegate: self)
    DeparturesManager.shared.stop = option
    self.stop = option
    self.setTitle(self.stop?.code)
    self.addMenuItem(with: WKMenuItemIcon.resume,
                     title: "Reload".localized,
                     action: #selector(self.refreshDepartures))
    self.errorLabel.setText("")
  }

  @objc func refreshDepartures() {
    DeparturesManager.shared.refreshDepartures()
  }

  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    guard let line = departures?.lines[rowIndex] else { return }
    guard let departures = self.departures else { return }
    pushController(withName: "departuresInterface", context: [departures, line])
  }

  func departuresDidUpdate() {
    self.departures = DeparturesManager.shared.departures
  }

  deinit {
    DeparturesManager.shared.removeDeparturesDelegate(delegate: self)
  }
}
