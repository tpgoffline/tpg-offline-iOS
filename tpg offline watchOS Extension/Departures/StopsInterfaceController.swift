//
//  StopsInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 07/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import WatchKit
import Foundation

class StopsInterfaceController: WKInterfaceController, AppDataChangedDelegate {

  @IBOutlet weak var tableView: WKInterfaceTable!
  let locationManager = CLLocationManager()
  @IBOutlet weak var loadingImage: WKInterfaceImage!

  var departureOption: DeparturesOption? = .allStops {
    didSet {
      if (departureOption ?? .allStops) == .nearestStops {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
      } else {
        self.loadTable()
      }
    }
  }
  var localizedStops: [Stop] = []

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    loadingImage.setImageNamed("loading-")
    loadingImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                      length: 60),
                                          duration: 2,
                                          repeatCount: -1)
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    guard let option = context as? DeparturesOption else {
      print("Context is not in a valid format")
      return
    }

    self.departureOption = option

    WatchSessionManager.sharedManager.addAppDataChangedDelegate(delegate: self)
  }

  func loadTable() {
    guard let departureOption = self.departureOption else { return }
    switch departureOption {
    case .nearestStops:
      tableView.setNumberOfRows(self.localizedStops.count, withRowType: "stopRow")
      for (index, stop) in self.localizedStops.enumerated() {
        guard let rowController =
          self.tableView.rowController(at: index) as? StopRowController
          else { continue }
        rowController.configure(with: stop, isNearestStops: true)
      }
    case .favorites:
      tableView.setNumberOfRows(App.favoritesStops.count, withRowType: "stopRow")
      for (index, id) in App.favoritesStops.enumerated() {
        guard let stop = App.stops.filter({
          $0.appId == id
        })[safe: 0] else { continue }
        guard let rowController = self.tableView.rowController(at: index)
          as? StopRowController else { continue }
        rowController.configure(with: stop)
      }
    case .allStops:
      tableView.setNumberOfRows(App.stops.count, withRowType: "stopRow")
      for (index, stop) in App.stops.enumerated() {
        guard let rowController = self.tableView.rowController(at: index)
          as? StopRowController else { continue }
        rowController.configure(with: stop)
      }
    }
    loadingImage.setImage(nil)
  }

  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    guard let rowController = self.tableView.rowController(at: rowIndex)
      as? StopRowController else { return }
    pushController(withName: "linesInterface", context: rowController.stop)
  }

  func appDataDidUpdate() {
    self.loadTable()
  }

  override func didDeactivate() {
    super.didDeactivate()
    WatchSessionManager.sharedManager.removeAppDataChangedDelegate(delegate: self)
  }
}

class StopRowController: NSObject {
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var group: WKInterfaceGroup!
  @IBOutlet weak var subTitleLabel: WKInterfaceLabel!

  var stop: Stop?

  func configure(with stop: Stop, isNearestStops: Bool = false) {
    self.stop = stop
    let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
    let subheadlineFont = UIFont.preferredFont(forTextStyle: .subheadline)
    let titleAttributes: [NSAttributedString.Key: Any]
    let subtitleAttributes: [NSAttributedString.Key: Any]
    if stop.subTitle != "", !isNearestStops {
      titleAttributes = [NSAttributedString.Key.font: subheadlineFont]
        as [NSAttributedString.Key: Any]
      subtitleAttributes = [NSAttributedString.Key.font: headlineFont]
        as [NSAttributedString.Key: Any]
    } else {
      titleAttributes = [NSAttributedString.Key.font: headlineFont]
        as [NSAttributedString.Key: Any]
      subtitleAttributes = [NSAttributedString.Key.font: subheadlineFont]
        as [NSAttributedString.Key: Any]
    }
    titleLabel.setAttributedText(
      NSAttributedString(string: stop.title,
                         attributes: titleAttributes))
    subTitleLabel.setAttributedText(
      NSAttributedString(string: stop.subTitle,
                         attributes: subtitleAttributes))
    if isNearestStops {
      titleLabel.setAttributedText(NSAttributedString(string: stop.name,
                                                      attributes: titleAttributes))
      let walkDuration = Int(stop.distance / 1000 / 5 * 60)
      let walkDurationString = Text.distance(meters: stop.distance,
                                             minutes: walkDuration)
      subTitleLabel.setAttributedText(
        NSAttributedString(string: walkDurationString,
                           attributes: subtitleAttributes))
    }
    subTitleLabel.setHidden(stop.subTitle == "")
  }
}

extension StopsInterfaceController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    if let location = locations[safe: 0] {
      self.localizedStops.removeAll()
      for stop in App.stops {
        var stopA = stop
        stopA.distance = location.distance(from: stopA.location)
        self.localizedStops.append(stopA)
      }
      self.localizedStops.sort(by: { $0.distance < $1.distance })
      self.localizedStops = Array(self.localizedStops.prefix(5))
      self.loadTable()
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    loadingImage.setImage(nil)
  }
}
