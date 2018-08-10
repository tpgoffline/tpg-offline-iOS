//
//  LineViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 13/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SafariServices
import Crashlytics
import Mapbox

class LineViewController: UIViewController {

  @IBOutlet weak var departureLabel: UILabel!
  @IBOutlet weak var arrivalLabel: UILabel!
  @IBOutlet weak var waybackMachineButton: UIButton!
  @IBOutlet weak var mapView: MGLMapView!

  @IBOutlet weak var arrowsImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var pathsSegmentedControl: UISegmentedControl!

  @IBOutlet weak var waybackMachineHeightConstraint: NSLayoutConstraint!

  var line: Line?
  var names: [String] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let line = self.line else { return }

    self.title = Text.line(line.line)

    App.log("Show line \(line.line)")
    App.logEvent("Show Orientation Line",
                 attributes: ["line": line.line])
    
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
    mapView.delegate = self
    mapView.showsUserLocation = true

    self.departureLabel.text = line.departureName
    self.departureLabel.textColor = App.textColor
    self.arrivalLabel.text = line.arrivalName
    self.arrivalLabel.textColor = App.textColor
    self.pathsSegmentedControl.removeAllSegments()
    for index in (0...line.courses.count - 1) {
      self.pathsSegmentedControl.insertSegment(withTitle: Text.path(index: index),
                                               at: index,
                                               animated: true)
    }
    self.pathsSegmentedControl.selectedSegmentIndex = 0
    self.departureLabel.text = App.stops.filter({
      $0.appId == line.courses[0].first
    }).first?.name ?? ""
    self.arrivalLabel.text = App.stops.filter({
      $0.appId == line.courses[0].last
    }).first?.name ?? ""
    var coordinates: [CLLocationCoordinate2D] = []
    for appId in line.courses[0] {
      if let stop = App.stops.filter({ $0.appId == appId}).first {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = stop.location.coordinate
        coordinates.append(stop.location.coordinate)
        annotation.title = stop.name
        self.names.append(stop.name)
        mapView.addAnnotation(annotation)
      }
    }

    let geodesic = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
    mapView.addAnnotation(geodesic)
    mapView.setCenter(coordinates.first!, zoomLevel: 14, animated: false)

    self.view.backgroundColor = App.cellBackgroundColor
    self.arrowsImageView.image = #imageLiteral(resourceName: "horizontalReverse").maskWith(color: App.textColor)

    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }

    if line.snotpgURL != "" {
      let color = App.color(for: line.line)
      let buttonColor = App.darkMode ? color : color.contrast
      waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: buttonColor), for: .normal)
      waybackMachineButton.setTitle("See line history".localized, for: .normal)
      waybackMachineButton.setTitleColor(buttonColor, for: .normal)
      waybackMachineButton.tintColor = App.darkMode ? color : color.contrast
      waybackMachineButton.addTarget(self,
                                     action: #selector(self.showSnotpgPage),
                                     for: .touchUpInside)
      waybackMachineButton.backgroundColor = App.darkMode ?
        .black : App.color(for: line.line)
      waybackMachineButton.cornerRadius = waybackMachineButton.bounds.height / 2
      waybackMachineButton.clipsToBounds = true
    } else {
      waybackMachineButton.isHidden = true
      waybackMachineHeightConstraint.priority = UILayoutPriority(997)
    }

    self.pathsSegmentedControl.tintColor = App.color(for: line.line)

    if App.darkMode {
      self.tableView.sectionIndexBackgroundColor = App.cellBackgroundColor
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.backgroundColor = .black
    }

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  @objc func showSnotpgPage() {
    guard let line = self.line else { return }
    let vc = SFSafariViewController(url: URL(string: line.snotpgURL)!,
                                    entersReaderIfAvailable: false)
    if App.darkMode, #available(iOS 10.0, *) {
      vc.preferredBarTintColor = .black
    }
    vc.delegate = self

    App.logEvent("Show SNOTPG Webpage",
                 attributes: ["line": line.line])

    self.present(vc, animated: true)
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.departureLabel.textColor = App.textColor
    self.arrivalLabel.textColor = App.textColor
    self.view.backgroundColor = App.cellBackgroundColor
    self.pathsSegmentedControl.tintColor = App.color(for: (line?.line)!)
    self.arrowsImageView.image = #imageLiteral(resourceName: "horizontalReverse").maskWith(color: App.textColor)
    self.tableView.backgroundColor = App.darkMode ? .black : .white
    self.tableView.reloadData()
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
    guard let line = self.line else { return }
    if line.snotpgURL != "" {
      let color = App.color(for: line.line)
      let buttonColor = App.darkMode ? color : color.contrast
      waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: buttonColor), for: .normal)
      waybackMachineButton.setTitleColor(buttonColor, for: .normal)
      waybackMachineButton.tintColor = buttonColor
      waybackMachineButton.backgroundColor = App.darkMode ?
        .black : App.color(for: line.line)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDepartures" {
      guard let destinationViewController = segue.destination
        as? DeparturesViewController else {
        return
      }
      let indexPath = tableView.indexPathForSelectedRow!
      self.tableView.deselectRow(at: indexPath, animated: true)
      destinationViewController.stop =
        (tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell)?.stop
    }
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  @IBAction func segmentedControlChanged() {
    self.tableView.reloadData()
    self.departureLabel.text = App.stops.filter({
      $0.appId == line?.courses[self.pathsSegmentedControl.selectedSegmentIndex].first
    }).first?.name ?? ""
    self.arrivalLabel.text = App.stops.filter({
      $0.appId == line?.courses[self.pathsSegmentedControl.selectedSegmentIndex].last
    }).first?.name ?? ""
    self.names = []
    guard let line = self.line else { return }
    if let annotations = mapView.annotations {
      mapView.removeAnnotations(annotations)
    }
    var coordinates: [CLLocationCoordinate2D] = []
    for appId in line.courses[self.pathsSegmentedControl.selectedSegmentIndex] {
      if let stop = App.stops.filter({ $0.appId == appId}).first {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = stop.location.coordinate
        coordinates.append(stop.location.coordinate)
        annotation.title = stop.name
        self.names.append(stop.name)
        mapView.addAnnotation(annotation)
      }
    }

    let geodesic = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
    mapView.add(geodesic)

    mapView.setCenter(coordinates.first!, zoomLevel: 14, animated: true)
  }
}

extension LineViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return
      line?.courses[safe: pathsSegmentedControl.selectedSegmentIndex]?.count ?? 0
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "busRouteCell",
      for: indexPath)
      as? BusRouteTableViewCell else {
        return UITableViewCell()
    }

    let course = self.line?.courses[safe:
      pathsSegmentedControl.selectedSegmentIndex]?[safe: indexPath.row] ?? 0
    let last = (indexPath.row + 1) ==
      self.line?.courses[safe: pathsSegmentedControl.selectedSegmentIndex]?.count
    cell.configure(with: course,
                   color: App.color(for: line?.line ?? ""),
                   first: indexPath.row == 0,
                   last: last)

    return cell
  }
}

extension LineViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    if let annotation = annotation as? MGLPointAnnotation {
      let titleSelected = annotation.title ?? ""
      if let index = self.names.index(of: titleSelected) {
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0),
                                   at: .top,
                                   animated: true)
      }
    }
  }
  
  func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    return App.color(for: line?.line ?? "")
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
}

extension LineViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true)
  }
}

extension LineViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    //swiftlint:disable:previous line_length

    guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

    guard let row = tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell
      else { return nil }

    guard let detailVC = storyboard?
      .instantiateViewController(withIdentifier: "departuresViewController")
        as? DeparturesViewController else { return nil }

    detailVC.stop = row.stop
    previewingContext.sourceRect = row.frame
    return detailVC
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
}
