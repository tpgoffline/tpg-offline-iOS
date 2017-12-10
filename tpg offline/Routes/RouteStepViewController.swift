//
//  RouteStepViewController.swift
//  tpg offline
//
//  Created by Remy on 08/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import MessageUI

class RouteStepViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!

    var section: RouteConnection.Sections!
    var color: UIColor = .black
    var names: [String] = []

    var titleSelected = "" {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = String(format: "Line %@".localized, "\(section.journey?.lineCode ?? "#!?".localized)")

        if section.journey?.compagny == "TPG" {
            self.color = App.color(for: section.journey?.lineCode ?? "")
        } else if section.journey?.compagny == "SBB" {
            title = String(format: "SBB %@".localized, "\(section.journey?.lineCode ?? "#!?".localized)")
            self.color = .red
        }

        self.reminderButton.setImage(#imageLiteral(resourceName: "cel-bell").maskWith(color: self.color.contrast), for: .normal)
        self.reminderButton.setTitleColor(self.color.contrast, for: .normal)
        self.reminderButton.backgroundColor = self.color
        self.reminderButton.cornerRadius = 5

        var coordinates: [CLLocationCoordinate2D] = []
        for step in section.journey?.passList ?? [] {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: step.station.coordinate.x, longitude: step.station.coordinate.y)
            coordinates.append(annotation.coordinate)
            annotation.title =  (App.stops.filter({$0.sbbId == step.station.id})[safe: 0]?.name)
                ?? step.station.name
            self.names.append((App.stops.filter({$0.sbbId == step.station.id})[safe: 0]?.name)
                ?? step.station.name)
            mapView.addAnnotation(annotation)
        }

        let geodesic = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.add(geodesic)

        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates[0],
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)

        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
    }

    @IBAction func remind() {
        let dateA = Date(timeIntervalSince1970: TimeInterval(self.section.departure.departureTimestamp!))
        let date = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: Date(), to: dateA)
        var alertController = UIAlertController(title: "Reminder".localized,
                                                message: "When do you want to be reminded?".localized,
                                                preferredStyle: .alert)
        if date.remainingMinutes == 0 {
            alertController.title = "Bus is comming".localized
            alertController.message = "You can't set a timer for this bus, but you should run to take it.".localized
        } else {
            let leftTime = date.remainingMinutes
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

        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func setAlert(with timeBefore: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(self.section.departure.departureTimestamp!))
            .addingTimeInterval(TimeInterval(timeBefore * -60))
        let components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: date)

        let destinationName = App.stops.filter({$0.nameTransportAPI == section.journey?.to})[safe: 0]?.name
            ?? (section.journey?.to ?? "#?!")

        if #available(iOS 10.0, *) {
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let content = UNMutableNotificationContent()

            content.title = timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)")

            content.body = String(format: "Take the line %@ to %@".localized, "\(section.journey?.lineCode ?? "#!?".localized)", destinationName)
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
                                                            message: String(format: "A notification will be send %@",
                                                                            (timeBefore == 0 ? "at the time of departure.".localized :
                                                                                String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            let notification = UILocalNotification()
            notification.fireDate = date
            if timeBefore == 0 {
                notification.alertBody = String(format: "Take the line %@ to %@ now".localized, "\(section.journey?.lineCode ?? "#!?".localized)", destinationName)
            } else {
                notification.alertBody = String(format: "Take the line %@ to %@ in %@ minutes".localized, "\(section.journey?.lineCode ?? "#!?".localized)", destinationName,
                    "\(timeBefore)")
            }
            notification.alertAction = "departureNotification"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}

extension RouteStepViewController: MKMapViewDelegate {
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
        guard let annotation = view.annotation else {
            return
        }
        titleSelected = (annotation.title ?? "") ?? ""
        if let index = self.names.index(of: titleSelected) {
            self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        titleSelected = ""
    }
}

extension RouteStepViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.journey?.passList.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepRow", for: indexPath)

        var titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                               NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        var subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline),
                                  NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        let routeResultsStop = self.section.journey?.passList[indexPath.row]

        let name = (App.stops.filter({$0.sbbId == routeResultsStop?.station.id ?? ""})[safe: 0]?.name)
            ?? (routeResultsStop?.station.name ?? "")

        if titleSelected == name {
            cell.backgroundColor = self.color
            titleAttributes[.foregroundColor] = self.color.contrast
            subtitleAttributes[.foregroundColor] = self.color.contrast
        } else {
            cell.backgroundColor = .white
        }

        cell.textLabel?.attributedText = NSAttributedString(string: name,
                                                            attributes: titleAttributes)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let hour: Date
        if let departureTimestamp = routeResultsStop?.departureTimestamp {
            hour = Date(timeIntervalSince1970: TimeInterval(departureTimestamp))
        } else {
            hour = Date(timeIntervalSince1970: TimeInterval(routeResultsStop?.arrivalTimestamp ?? 0))
        }

        cell.detailTextLabel?.attributedText = NSAttributedString(string: dateFormatter.string(from: hour),
                                                                  attributes: subtitleAttributes)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = tableView.cellForRow(at: indexPath)
        titleSelected = row?.textLabel?.text ?? ""
        guard let annotiation = mapView.annotations.filter({ $0.title ?? "#" == titleSelected })[safe: 0] else {
            return
        }
        mapView.selectAnnotation(annotiation, animated: true)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotiation.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension RouteStepViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
