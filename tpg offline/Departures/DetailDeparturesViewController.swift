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
#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

class DetailDeparturesViewController: UIViewController {

    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var allDeparturesButton: UIButton!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var buttonsView: UIView!

    var departure: Departure?
    var busRouteGroup: BusRouteGroup? {
        didSet {
            self.tableView.reloadData()
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)

            guard let busRouteGroup = self.busRouteGroup else { return }

            let indexPath = IndexPath(row:
                (busRouteGroup.steps.count) -
                    (busRouteGroup.steps.filter({ $0.arrivalTime != "" }).count), section: 0)
            if self.tableView.numberOfRows(inSection: 0) > indexPath.row {
                DispatchQueue.main.async {
                self.tableView.scrollToRow(at: indexPath,
                                           at: UITableViewScrollPosition.top,
                                           animated: false)
                }
            }

            let steps = busRouteGroup.steps
            var coordinates: [CLLocationCoordinate2D] = []
            var passedCoordinated: [CLLocationCoordinate2D] = []
            var passed = true
            for step in steps {
                guard let stop = App.stops.filter({ $0.code == step.stop.code })[safe: 0] else { break }
                let annotation = MKPointAnnotation()
                if let localisation = stop.localisations.filter({ !($0.destinations.filter({ $0.line == busRouteGroup.lineCode && $0.destination == busRouteGroup.destination }).isEmpty) })[safe: 0] {
                    annotation.coordinate = localisation.location.coordinate
                } else {
                    annotation.coordinate = stop.location.coordinate
                }

                if step.arrivalTime == "" {
                    passedCoordinated.append(annotation.coordinate)
                } else if step.arrivalTime != "", passed {
                    passedCoordinated.append(annotation.coordinate)
                    coordinates.append(annotation.coordinate)
                    passed = false
                } else {
                    coordinates.append(annotation.coordinate)
                }

                annotation.title = stop.name
                self.names.append(stop.name)
                mapView.addAnnotation(annotation)
            }

            let geodesicPassed = MKPolyline(coordinates: &passedCoordinated, count: passedCoordinated.count)
            geodesicPassed.title = "Passed Stops"
            mapView.add(geodesicPassed)
            let geodesic = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            geodesic.title = "Next Stops"
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

        if App.darkMode {
            self.buttonsView.backgroundColor = .black
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }

        if let color = self.color {
            self.reminderButton.setImage(#imageLiteral(resourceName: "cel-bell").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            self.allDeparturesButton.setImage(#imageLiteral(resourceName: "clockTabBar").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            self.wifiButton.setImage(#imageLiteral(resourceName: "wifi").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)

            self.reminderButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            self.reminderButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
            self.reminderButton.cornerRadius = 5
            self.allDeparturesButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            self.allDeparturesButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
            self.allDeparturesButton.cornerRadius = 5
            self.wifiButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            self.wifiButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
            self.wifiButton.cornerRadius = 5
        }

        refreshBusRoute()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }

        refreshControl.addTarget(self, action: #selector(refreshBusRoute), for: .valueChanged)
        refreshControl.tintColor = color

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.refreshBusRoute),
                            accessbilityLabel: "Reload".localized)
        ]

        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.tableView)
        }

        if self.departure?.wifi == false {
            self.wifiButton.isHidden = true
        }
        if #available(iOS 11.0, *) {} else {
            self.wifiButton.isHidden = true
        }
        #if !arch(i386) && !arch(x86_64)
        #else
        self.wifiButton.isHidden = true
        #endif

        ColorModeManager.shared.addColorModeDelegate(self)
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func colorModeDidUpdated() {
        super.colorModeDidUpdated()
        self.buttonsView.backgroundColor = App.darkMode ? .black : .white
        self.tableView.backgroundColor = App.darkMode ? .black : .white
        self.tableView.separatorColor = App.separatorColor
        self.tableView.reloadData()

        if let color = self.color {
            self.reminderButton.setImage(#imageLiteral(resourceName: "cel-bell").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            self.allDeparturesButton.setImage(#imageLiteral(resourceName: "clockTabBar").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)

            self.reminderButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            self.reminderButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
            self.allDeparturesButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            self.allDeparturesButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
            self.wifiButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            self.wifiButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
        }
    }

    @objc func refreshBusRoute() {
        self.busRouteGroup = nil
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetThermometer.json", method: .get,
                          parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b",
                                       "departureCode": departure?.code ?? 0])
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                    let json = try? jsonDecoder.decode(BusRouteGroup.self, from: data)

                    self.busRouteGroup = json
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
            App.log("Departures: Show all departures")
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

    @IBAction func connectToWifi() {
        #if !arch(i386) && !arch(x86_64)
        if #available(iOS 11.0, *) {
            let configuration = NEHotspotConfiguration(ssid: "tpg-freeWiFi")
            configuration.joinOnce = false
            NEHotspotConfigurationManager.shared.apply(configuration, completionHandler: { (error) in
                print(error ?? "")
            })
        } else {
            print("How did you ended here ?")
        }
        #endif
    }

    @IBAction func remind() {
        App.log("Departures: Reminder")
        self.departure?.calculateLeftTime()
        let leftTime = Int(self.departure?.leftTime ?? "0".localized) ?? 0
        var alertController = UIAlertController(title: "Reminder".localized,
                                                message: String(format: "At %@ - In %@ minutes\nWhen do you want to be reminded?".localized, stop?.name ?? "??", "\(leftTime)"),
                                                preferredStyle: .alert)
        if self.departure?.leftTime == "0" {
            alertController.title = "Bus is comming".localized
            alertController.message = "You can't set a timer for this bus, but you should run to take it.".localized
        } else {
            let departureTimeAction = UIAlertAction(title: "At departure time".localized, style: .default) { _ in
                self.setAlert(with: 0, date: (self.departure?.dateCompenents?.date ?? Date()), fromName: self.stop?.name ?? "", fromCode: self.stop?.code ?? "")
            }
            alertController.addAction(departureTimeAction)

            if leftTime > 5 {
                let fiveMinutesBeforeAction = UIAlertAction(title: "5 minutes before".localized, style: .default) { _ in
                    self.setAlert(with: 5, date: (self.departure?.dateCompenents?.date ?? Date()), fromName: self.stop?.name ?? "", fromCode: self.stop?.code ?? "")
                }
                alertController.addAction(fiveMinutesBeforeAction)
            }
            if leftTime > 10 {
                let tenMinutesBeforeAction = UIAlertAction(title: "10 minutes before".localized, style: .default) { _ in
                    self.setAlert(with: 10, date: (self.departure?.dateCompenents?.date ?? Date()), fromName: self.stop?.name ?? "", fromCode: self.stop?.code ?? "")
                }
                alertController.addAction(tenMinutesBeforeAction)
            }

            let otherAction = UIAlertAction(title: "Other".localized, style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                alertController = UIAlertController(title: "Reminder".localized,
                                                    message: "When do you want to be reminded".localized,
                                                    preferredStyle: .alert)

                alertController.addTextField { textField in
                    textField.placeholder = "Number of minutes before departure".localized
                    textField.keyboardType = .numberPad
                    textField.keyboardAppearance = App.darkMode ? .dark : .light
                }

                let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
                    guard let remainingTime = Int(alertController.textFields?[0].text ?? "#!?") else { return }
                    self.setAlert(with: remainingTime, date: (self.departure?.dateCompenents?.date ?? Date()), fromName: self.stop?.name ?? "", fromCode: self.stop?.code ?? "")
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

    func setAlert(with timeBefore: Int, date: Date, fromName: String, fromCode: String, forceDisableSmartReminders: Bool = false) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, _) in
                if !accepted {
                    print("Notification access denied.")
                }
            }
        } else {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        let newDate = date.addingTimeInterval(TimeInterval(timeBefore * -60))
        let components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: newDate)
        if App.smartReminders, !forceDisableSmartReminders, let departure = self.departure, departure.code != -1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            var parameters: Parameters = [
                "device": App.apnsToken,
                "departureCode": departure.code,
                "title": timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)"),
                "text": String(format: "Take the line %@ to %@ at %@".localized,
                               departure.line.code, departure.line.destination, fromName),
                "line": departure.line.code,
                "reminderTimeBeforeDeparture": timeBefore,
                "stopCode": fromCode,
                "estimatedArrivalTime": formatter.string(from: date),
                "sandbox": false
            ]
            #if DEBUG
            parameters["sandbox"] = true
            #endif
            Alamofire.request("https://tpgoffline-apns.alwaysdata.net/reminders/add", method: .post, parameters: parameters).responseString(completionHandler: { (response) in
                dump(response)
                if let string = response.result.value, string == "1" {
                    let alertController = UIAlertController(title: "You will be reminded".localized,
                                                            message: String(format: "A notification will be send %@".localized,
                                                                            (timeBefore == 0 ? "at the time of departure.".localized :
                                                                                String(format: "%@ minutes before.".localized, "\(timeBefore)"))),
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else if let string = response.result.value, string == "0" {
                    let alertController = UIAlertController(title: "Duplicated reminder".localized,
                                                            message: "We already sheduled a reminder with these parameters.".localized,
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Error".localized, message: "Sorry, but we were not able to add your smart notification. Do you want to try again?".localized, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Try again".localized, style: .default, handler: { (_) in
                        self.setAlert(with: timeBefore, date: newDate, fromName: fromName, fromCode: fromCode, forceDisableSmartReminders: false)
                    }))
                    alertController.addAction(UIAlertAction(title: "Try again without Smart Reminders".localized, style: .default, handler: { (_) in
                        self.setAlert(with: timeBefore, date: newDate, fromName: fromName, fromCode: fromCode, forceDisableSmartReminders: true)
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            if #available(iOS 10.0, *) {
                dump(components)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let content = UNMutableNotificationContent()

                content.title = timeBefore == 0 ? "The bus is comming now!".localized : String(format: "%@ minutes left!".localized, "\(timeBefore)")
                content.body = String(format: "Take the line %@ to %@ at %@".localized,
                                      "\(departure?.line.code ?? "#?!".localized)", "\(departure?.line.destination ?? "#?!".localized)", fromName)
                content.sound = UNNotificationSound.default()
                let request = UNNotificationRequest(identifier: "departureNotification-\(String.random(30))", content: content, trigger: trigger)
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
            } else {
                let notification = UILocalNotification()
                notification.fireDate = newDate
                if timeBefore == 0 {
                    notification.alertBody = String(format: "Take the line %@ to %@ now".localized,
                                                    "\(departure?.line.code ?? "#?!".localized)", "\(departure?.line.destination ?? "#?!".localized)")
                } else {
                    notification.alertBody = String(format: "Take the line %@ to %@ in %@ minutes".localized,
                                                    "\(departure?.line.code ?? "#?!".localized)", "\(departure?.line.destination ?? "#?!".localized)",
                        "\(timeBefore)")
                }
                notification.identifier = "departureNotification-\(String.random(30))"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
    }
}

extension DetailDeparturesViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return busRouteGroup!.steps[indexPath.row].arrivalTime != ""
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reminderAction = UITableViewRowAction(style: .normal, title: "Reminder".localized) { (_, _) in
            App.log("Departures: Reminder")
            let leftTime = Int(self.busRouteGroup!.steps[indexPath.row].arrivalTime) ?? -1
            var alertController = UIAlertController(title: "Reminder".localized,
                                                    message: String(format: "At %@ - In %@ minutes\nWhen do you want to be reminded?".localized, self.stop?.name ?? "??", "\(leftTime)"),
                                                    preferredStyle: .alert)
            if leftTime == 0 {
                alertController.title = "Bus is comming".localized
                alertController.message = "You can't set a timer for this bus, but you should run to take it.".localized
            } else {
                let departureTimeAction = UIAlertAction(title: "At departure time".localized, style: .default) { _ in
                    self.setAlert(with: 0, date: self.busRouteGroup!.steps[indexPath.row].timestamp, fromName: self.busRouteGroup!.steps[indexPath.row].stop.name, fromCode: self.busRouteGroup!.steps[indexPath.row].stop.code)
                }
                alertController.addAction(departureTimeAction)

                if leftTime > 5 {
                    let fiveMinutesBeforeAction = UIAlertAction(title: "5 minutes before".localized, style: .default) { _ in
                        self.setAlert(with: 5, date: self.busRouteGroup!.steps[indexPath.row].timestamp, fromName: self.busRouteGroup!.steps[indexPath.row].stop.name, fromCode: self.busRouteGroup!.steps[indexPath.row].stop.code)
                    }
                    alertController.addAction(fiveMinutesBeforeAction)
                }
                if leftTime > 10 {
                    let tenMinutesBeforeAction = UIAlertAction(title: "10 minutes before".localized, style: .default) { _ in
                        self.setAlert(with: 10, date: self.busRouteGroup!.steps[indexPath.row].timestamp, fromName: self.busRouteGroup!.steps[indexPath.row].stop.name, fromCode: self.busRouteGroup!.steps[indexPath.row].stop.code)
                    }
                    alertController.addAction(tenMinutesBeforeAction)
                }

                let otherAction = UIAlertAction(title: "Other".localized, style: .default) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                    alertController = UIAlertController(title: "Reminder".localized,
                                                        message: "When do you want to be reminded".localized,
                                                        preferredStyle: .alert)

                    alertController.addTextField { textField in
                        textField.placeholder = "Number of minutes before departure".localized
                        textField.keyboardType = .numberPad
                        textField.keyboardAppearance = App.darkMode ? .dark : .light
                    }

                    let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
                        guard let remainingTime = Int(alertController.textFields?[0].text ?? "#!?") else { return }
                        self.setAlert(with: remainingTime, date: self.busRouteGroup!.steps[indexPath.row].timestamp, fromName: self.busRouteGroup!.steps[indexPath.row].stop.name, fromCode: self.busRouteGroup!.steps[indexPath.row].stop.code)
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

            self.present(alertController, animated: true, completion: nil)
        }
        if App.darkMode {
            reminderAction.backgroundColor = .black
        } else {
            reminderAction.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
        }
        return [reminderAction]
    }
}

extension DetailDeparturesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if ((overlay.title ?? "") ?? "") == "Passed Stops" {
                polylineRenderer.strokeColor = .gray
            } else {
                polylineRenderer.strokeColor = self.color
            }
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
