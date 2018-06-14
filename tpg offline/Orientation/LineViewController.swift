//
//  LineViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 13/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import SafariServices
import Crashlytics
import MapKit

class LineViewController: UIViewController {

    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var waybackMachineButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var arrowsImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pathsSegmentedControl: UISegmentedControl!

    var line: Line?
    var names: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let line = self.line else { return }

        self.title = String(format: "Line %@".localized, line.line)

        App.log("Show line \(line.line)")
        Answers.logCustomEvent(withName: "Show Orientation Line",
                               customAttributes: ["line": line.line])

        self.departureLabel.text = line.departureName
        self.departureLabel.textColor = App.textColor
        self.arrivalLabel.text = line.arrivalName
        self.arrivalLabel.textColor = App.textColor
        self.pathsSegmentedControl.removeAllSegments()
        for index in (0...line.courses.count - 1) {
            self.pathsSegmentedControl.insertSegment(withTitle: String(format: "Path %@".localized, "\(index + 1)"), at: index, animated: true)
        }
        self.pathsSegmentedControl.selectedSegmentIndex = 0
        self.departureLabel.text = App.stops.filter({ $0.appId == line.courses[0].first}).first?.name ?? ""
        self.arrivalLabel.text = App.stops.filter({ $0.appId == line.courses[0].last}).first?.name ?? ""
        var coordinates: [CLLocationCoordinate2D] = []
        for appId in line.courses[0] {
            if let stop = App.stops.filter({ $0.appId == appId}).first {
                let annotation = MKPointAnnotation()
                annotation.coordinate = stop.location.coordinate
                coordinates.append(stop.location.coordinate)
                annotation.title = stop.name
                self.names.append(stop.name)
                mapView.addAnnotation(annotation)
            }
        }
        
        let geodesic = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.add(geodesic)
        
        let regionRadius: CLLocationDistance = 1000
        let centerPoint: CLLocationCoordinate2D = coordinates.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPoint,
                                                              regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)

        self.view.backgroundColor = App.cellBackgroundColor
        self.arrowsImageView.image = #imageLiteral(resourceName: "horizontalReverse").maskWith(color: App.textColor)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        if line.snotpgURL != "" {
            let color = App.color(for: line.line)
            waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            waybackMachineButton.setTitle("See line history".localized, for: .normal)
            waybackMachineButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            waybackMachineButton.tintColor = App.darkMode ? color : color.contrast
            waybackMachineButton.addTarget(self, action: #selector(self.showSnotpgPage), for: .touchUpInside)
            waybackMachineButton.backgroundColor = App.darkMode ? .black : App.color(for: line.line)
            waybackMachineButton.cornerRadius = waybackMachineButton.bounds.height / 2
            waybackMachineButton.clipsToBounds = true
        } else {
            waybackMachineButton.isHidden = true
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
        let vc = SFSafariViewController(url: URL(string: line.snotpgURL)!, entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
            vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        Answers.logCustomEvent(withName: "Show SNOTPG Webpage",
                               customAttributes: ["line": line.line])

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
        guard let line = self.line else { return }
        if line.snotpgURL != "" {
            let color = App.color(for: line.line)
            waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            waybackMachineButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            waybackMachineButton.tintColor = App.darkMode ? color : color.contrast
            waybackMachineButton.backgroundColor = App.darkMode ? .black : App.color(for: line.line)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDepartures" {
            guard let destinationViewController = segue.destination as? DeparturesViewController else {
                return
            }
            let indexPath = tableView.indexPathForSelectedRow!
            self.tableView.deselectRow(at: indexPath, animated: true)
            destinationViewController.stop = (tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell)?.stop
        }
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }
    
    @IBAction func segmentedControlChanged() {
        self.tableView.reloadData()
        self.departureLabel.text = App.stops.filter({ $0.appId == line?.courses[self.pathsSegmentedControl.selectedSegmentIndex].first}).first?.name ?? ""
        self.arrivalLabel.text = App.stops.filter({ $0.appId == line?.courses[self.pathsSegmentedControl.selectedSegmentIndex].last}).first?.name ?? ""
        self.names = []
        guard let line = self.line else { return }
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        var coordinates: [CLLocationCoordinate2D] = []
        for appId in line.courses[self.pathsSegmentedControl.selectedSegmentIndex] {
            if let stop = App.stops.filter({ $0.appId == appId}).first {
                let annotation = MKPointAnnotation()
                annotation.coordinate = stop.location.coordinate
                coordinates.append(stop.location.coordinate)
                annotation.title = stop.name
                self.names.append(stop.name)
                mapView.addAnnotation(annotation)
            }
        }
        
        let geodesic = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.add(geodesic)
        
        let regionRadius: CLLocationDistance = 1000
        let centerPoint: CLLocationCoordinate2D = coordinates.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPoint,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension LineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.line?.courses[safe: pathsSegmentedControl.selectedSegmentIndex]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "busRouteCell",
            for: indexPath)
            as? BusRouteTableViewCell else {
                return UITableViewCell()
        }

        cell.configure(with: self.line?.courses[safe: pathsSegmentedControl.selectedSegmentIndex]?[safe: indexPath.row] ?? 0,
                       color: App.color(for: line?.line ?? ""),
                       first: indexPath.row == 0,
                       last: (indexPath.row + 1) == self.line?.courses[safe: pathsSegmentedControl.selectedSegmentIndex]?.count)

        return cell
    }
}

extension LineViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = App.color(for: line?.line ?? "")
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let titleSelected = view.annotation?.title! ?? ""
        if let index = self.names.index(of: titleSelected) {
            self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        //titleSelected = ""
    }
}

extension LineViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

extension LineViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "departuresViewController") as? DeparturesViewController
            else { return nil }

        detailVC.stop = row.stop
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
