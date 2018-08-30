//
//  DisruptionsInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 11/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class DisruptionsInterfaceController: WKInterfaceController {

  @IBOutlet weak var tableView: WKInterfaceTable!
  @IBOutlet weak var loadingImage: WKInterfaceImage!

  var disruptions: DisruptionsGroup? = nil {
    didSet {
      guard let disruptionsA = self.disruptions else {
        self.loadingImage.setImage(nil)
        return
      }
      var disruptions: [Disruption] = []
      for (_, disruption) in disruptionsA.disruptions {
        disruptions.append(contentsOf: disruption)
      }
      disruptions.sort(by: { $0.line < $1.line })
      self.tableView.setNumberOfRows(disruptions.count, withRowType: "disruptionRow")
      for (index, disruption) in disruptions.enumerated() {
        guard let rowController = self.tableView.rowController(at: index) as?
          DisruptionsRowController else { continue }
        rowController.disruption = disruption
      }
      self.loadingImage.setImage(nil)
    }
  }

  var requestStatus: RequestStatus  = .loading {
    didSet {
      if requestStatus == .error {
      }
    }
  }

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    self.setTitle("Disruptions".localized)
    self.addMenuItem(with: WKMenuItemIcon.resume,
                     title: "Reload".localized,
                     action: #selector(self.reload))
    reload()
  }

  @objc func reload() {
    loadingImage.setImageNamed("loading-")
    loadingImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                      length: 60),
                                          duration: 2,
                                          repeatCount: -1)
    Alamofire.request(URL.disruptions,
                      method: .get,
                      parameters: ["key": API.tpg])
      .responseData { (response) in
        if let data = response.result.value {
          let jsonDecoder = JSONDecoder()
          let json = try? jsonDecoder.decode(DisruptionsGroup.self, from: data)
          self.requestStatus = json?.disruptions.count ?? 0 == 0 ? .noResults : .ok
          self.disruptions = json
        } else {
          self.loadingImage.setImage(nil)
          self.requestStatus = .error
        }
    }
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}

class DisruptionsRowController: NSObject {
  @IBOutlet var titleLabel: WKInterfaceLabel!
  @IBOutlet var subTitleLabel: WKInterfaceLabel!
  @IBOutlet var group: WKInterfaceGroup!

  var disruption: Disruption! {
    didSet {
      self.titleLabel.setText(Text.line(disruption.line,
                                        destination: disruption.nature))
      self.subTitleLabel.setText(String(format: disruption.consequence))
      self.titleLabel.setTextColor(
        LineColorManager.color(for: disruption.line).contrast)
      self.subTitleLabel.setTextColor(
        LineColorManager.color(for: disruption.line).contrast)
      self.group.setBackgroundColor(LineColorManager.color(for: disruption.line))
    }
  }
}
