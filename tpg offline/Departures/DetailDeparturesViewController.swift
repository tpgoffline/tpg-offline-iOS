//
//  DetailDeparturesViewController.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 11/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import MapKit
import MessageUI

class DetailDeparturesViewController: UIViewController {

    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var allDeparturesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stackView: UIStackView!

    var departure: Departure?
    var busRouteGroup: BusRouteGroup? {
        didSet {
            self.tableView.reloadData()
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)

            guard let busRouteGroup = self.busRouteGroup else { return }

            let stops = busRouteGroup.steps.map({ $0.stop.code })
            var coordinates: [CLLocationCoordinate2D] = []
            for stopCode in stops {
                guard let stop = App.stops.filter({ $0.code == stopCode })[safe: 0] else { break }
                let annotation = MKPointAnnotation()
                annotation.coordinate = stop.location.coordinate
                coordinates.append(annotation.coordinate)
                annotation.title = stop.name
                self.names.append(stop.name)
                mapView.addAnnotation(annotation)
            }

            let geodesic = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            mapView.add(geodesic)

            let regionRadius: CLLocationDistance = 1000
            let centerPoint: CLLocationCoordinate2D
            if busRouteGroup.steps.filter({ $0.stop.code == self.stop?.code })[0].arrivalTime == "" {
                guard let i = busRouteGroup.steps.filter({ $0.arrivalTime != "" })[safe: 0] else {
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates.last ??
                        CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                                                              regionRadius * 2.0, regionRadius * 2.0)
                    mapView.setRegion(coordinateRegion, animated: true)
                    return
                }
                let nextStop = i.stop.code
                let stop = App.stops.filter({ $0.code == nextStop })[safe: 0]
                centerPoint = stop?.location.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            } else {
                centerPoint = coordinates.filter({ $0 == (self.stop?.location.coordinate)! })[safe: 0] ?? coordinates[0]
            }
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPoint,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    var color: UIColor?
    var stop: Stop?
    var names: [String] = []

    var titleSelected = "" {
        didSet {
            self.tableView.reloadData()
        }
    }

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = String(format: "Line %@".localized, "\(departure?.line.code ?? "?#!".localized)")

        if let color = self.color {
            self.reminderButton.setImage(#imageLiteral(resourceName: "cel-bell").maskWith(color: color.contrast), for: .normal)
            self.allDeparturesButton.setImage(#imageLiteral(resourceName: "clockTabBar").maskWith(color: color.contrast), for: .normal)

            self.reminderButton.setTitleColor(color.contrast, for: .normal)
            self.reminderButton.backgroundColor = color
            self.reminderButton.cornerRadius = 5
            self.allDeparturesButton.setTitleColor(color.contrast, for: .normal)
            self.allDeparturesButton.backgroundColor = color
            self.allDeparturesButton.cornerRadius = 5
        }

        refreshBusRoute()

        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refreshBusRoute), for: .valueChanged)
        refreshControl.tintColor = color

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.refreshBusRoute))
        ]

        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.tableView)
        }
    }

    @objc func refreshBusRoute() {
        self.busRouteGroup = nil
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetThermometer", method: .get,
                          parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b",
                                       "departureCode": departure?.code ?? 0])
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601
                    let json = try? jsonDecoder.decode(BusRouteGroup.self, from: data)

                    self.busRouteGroup = json

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.tableView.scrollToRow(at: IndexPath(row:
                            (self.busRouteGroup?.steps.count)! - (self.busRouteGroup?.steps.filter({ $0.arrivalTime != "" }).count)!, section: 0),
                                                   at: UITableViewScrollPosition.top,
                                                   animated: true)
                    }

                }
                self.refreshControl.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStopFromBusRoute" {
            guard let destinationViewController = segue.destination as? DeparturesViewController else {
                return
            }
            let indexPath = tableView.indexPathForSelectedRow!
            self.tableView.deselectRow(at: indexPath, animated: true)
            destinationViewController.stop = App.stops.filter({ $0.code ==
                (tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell)?.busRoute?.stop.code })[safe: 0]
        } else if segue.identifier == "allDepartures" {
            guard let destinationViewController = segue.destination as? AllDeparturesCollectionViewController else {
                return
            }
            destinationViewController.departure = self.departure
            destinationViewController.stop = self.stop
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
    }

    @IBAction func remind() {
        self.departure?.calculateLeftTime()
        var alertController = UIAlertController(title: "Reminder".localized,
                                                message: "When do you want to be reminded?".localized,
                                                preferredStyle: .alert)
        if self.departure?.leftTime == "0" {
            alertController.title = "Bus is comming".localized
            alertController.message = "You can't set a timer for this bus, but you should run to take it.".localized
        } else {
            let leftTime = Int(self.departure?.leftTime ?? "0".localized) ?? 0
            let departureTimeAction = UIAlertAction(title: "At departure time".localized, style: .default) { _ in
                self.setAlert(with: 0)
            }
            alertController.addAction(departureTimeAction)

            if leftTime > 5 {
                let fiveMinutesBeforeAction = UIAlertAction(title: "5 minutes before".localized, style: .default) { _ in
                    self.setAlert(with: 5)
                }
                alertController.addAction(fiveMinutesBeforeAction)
            }
            if leftTime > 10 {
                let tenMinutesBeforeAction = UIAlertAction(title: "10 minutes before".localized, style: .default) { _ in
                    self.setAlert(with: 10)
                }
                alertController.addAction(tenMinutesBeforeAction)
            }

            let otherAction = UIAlertAction(title: "Other".localized, style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                alertController = UIAlertController(title: "Reminder".localized,
                                                    message: "When do you want to be reminded".localized,
                                                    preferredStyle: .alert)

                alertController.addTextField { textField in
                    textField.placeholder = "Number of minutes".localized
                    textField.keyboardType = .numberPad
                }

                let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
                    guard let remainingTime = Int(alertController.textFields?[0].text ?? "#!?") else { return }
                    self.setAlert(with: remainingTime)
                }
                alertController.addAction(okAction)

                let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive) { _ in
                }
                alertController.addAction(cancelAction)

                self.present(alertController, animated: true, completion: nil)
            }

            alertController.addAction(otherAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive) { _ in }
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func setAlert(with timeBefore: Int) {
        self.departure?.calculateLeftTime()
        let date = departure?.dateCompenents?.date?.addingTimeInterval(TimeInterval(timeBefore * -60))
        let components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: date ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()

        content.title = timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)")
        content.body = String(format: "Take the line %@ to %@".localized,
                              "\(departure?.line.code ?? "#?!".localized)", "\(departure?.line.destination ?? "#?!".localized)")
        content.sound = UNNotificationSound.default()
        content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
        let request = UNNotificationRequest(identifier: "departureNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
                let alertController = UIAlertController(title: "An error occurred".localized,
                                                        message: "Sorry for that. Can you try again, or send an email to us if the problem persist?".localized, // swiftlint:disable:this line_length
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Send email", style: .default, handler: { (_) in
                    let mailComposerVC = MFMailComposeViewController()
                    mailComposerVC.mailComposeDelegate = self

                    mailComposerVC.setToRecipients(["support@asmartcode.com"])
                    mailComposerVC.setSubject("tpg offline - Bug report")
                    mailComposerVC.setMessageBody("\(error.localizedDescription)", isHTML: false)

                    if MFMailComposeViewController.canSendMail() {
                        self.present(mailComposerVC, animated: true, completion: nil)
                    }
                }))

                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "You will be reminded".localized,
                                                        message: String(format: "A notification will be send %@".localized,
                                                                        (timeBefore == 0 ? "at the time of departure.".localized :
                                                                            String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension DetailDeparturesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busRouteGroup?.steps.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "busRouteCell",
            for: indexPath)
            as? BusRouteTableViewCell else {
                return UITableViewCell()
        }

        guard let stop = App.stops.filter({ $0.code == busRouteGroup!.steps[indexPath.row].stop.code })[safe: 0]
            else { return UITableViewCell() }

        cell.configure(with: busRouteGroup!.steps[indexPath.row],
                       color: App.color(for: busRouteGroup!.lineCode),
                       selected: titleSelected == stop.name)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension DetailDeparturesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = self.color
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }

        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        titleSelected = view.annotation?.title! ?? ""
        if let index = self.names.index(of: titleSelected) {
            self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        titleSelected = ""
    }
}

extension DetailDeparturesViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension DetailDeparturesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "departuresViewController") as? DeparturesViewController
            else { return nil }

        detailVC.stop = App.stops.filter({ $0.code == row.busRoute?.stop.code })[safe: 0]
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        show(viewControllerToCommit, sender: self)

    }
}
