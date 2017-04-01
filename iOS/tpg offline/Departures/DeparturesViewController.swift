//
//  DeparturesViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Alamofire
import WatchConnectivity
import UserNotifications
import FirebaseCrash
import FirebaseAnalytics
import DGElasticPullToRefresh
import SCLAlertView
import SwiftyJSON
import MapKit

struct StopLinesList {
    static var linesList: [String] = []
    static var linesDisabled: [String] = []
    static var filterNoMore: Bool = false
}

class DeparturesViewController: UIViewController {
    var stop: Stop?
    var initialDeparturesList: [Departures]! = []
    var departuresList: [Departures]! = []
    let defaults = UserDefaults.standard
    var offline = false
    var noMoreTransport = false
    var loading: Bool = false
    var notDownloaded: Bool = false
    var timeToGo: Int = -1
    var route: MKRoute?
    var routeArea: MKMapRect?
    var routeActivated: Bool = false
    var recenterMap: Bool = true
    var selectedIndexPath: IndexPath?

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapViewHeightConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        if stop == nil {
            stop = AppValues.stops[[String](AppValues.stops.keys).sorted()[0]]
        }

        StopLinesList.linesList = []

        #if DEBUG
        #else
            FIRAnalytics.logEvent(withName: "departure", parameters: [
                "stopCode": (stop?.stopCode ?? "XXXX") as NSObject
                ])
        #endif

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor

        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refresh()

            }, loadingView: loadingView)

        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(percentage: 0.1)!)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        title = stop?.fullName

        tableView.backgroundColor = AppValues.primaryColor

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        refresh()
        configureDescriptionOfStop()

        FIRCrashMessage("\(String(describing: stop?.stopCode)) loaded")
    }

    func configureDescriptionOfStop() {
        coordinate = stop!.location.coordinate

        let pin = MKPointAnnotation()
        pin.coordinate = self.stop!.location.coordinate
        pin.title = self.stop!.fullName ?? "Carotte ?"
        mapView.addAnnotation(pin)
        mapView.delegate = self

        if AppValues.primaryColor.contrast == .white {
            mapView.tintColor = AppValues.primaryColor
        } else {
            mapView.tintColor = AppValues.textColor
        }
        titleLabel.text = stop?.fullName ?? ""

        centerButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1003521127)
        centerButton.layer.cornerRadius = centerButton.bounds.height / 2
        centerButton.addTarget(self, action: #selector(centerMap), for: .touchUpInside)

        routeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1003521127)
        routeButton.addTarget(self, action: #selector(showRoute), for: .touchUpInside)
        routeButton.layer.cornerRadius = routeButton.bounds.height / 2

        mapView.removeOverlays(mapView.overlays)
        if routeActivated, let route = self.route, let routeArea = self.routeArea {
            mapView.add(route.polyline)
            mapView.setVisibleMapRect(routeArea, animated: true)
            recenterMap = false
        }
        if recenterMap {
            centerMap()
            recenterMap = false
        }

        if timeToGo != -1 {
            routeButton.setTitle("\(timeToGo) min", for: .normal)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(percentage: 0.1)!)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        if stop != nil {
            var barButtonsItems: [UIBarButtonItem] = []

            if (AppValues.fullNameFavoritesStops.index(of: stop!.fullName)) != nil {
                barButtonsItems.append(UIBarButtonItem(
                    image: #imageLiteral(resourceName: "starNavbar"),
                    style: UIBarButtonItemStyle.done,
                    target: self,
                    action: #selector(self.toggleFavorite(_:))))
            } else {
                barButtonsItems.append(UIBarButtonItem(
                    image: #imageLiteral(resourceName: "starEmptyNavbar"),
                    style: UIBarButtonItemStyle.done,
                    target: self,
                    action:#selector(self.toggleFavorite(_:))))
            }
            barButtonsItems.append(
                UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                                style: UIBarButtonItemStyle.done,
                                target: self,
                                action: #selector(self.refresh)))

            self.navigationItem.rightBarButtonItems = barButtonsItems
        }

        departuresList = initialDeparturesList.filter { (departure) -> Bool in
            if StopLinesList.filterNoMore && departure.leftTime == "no more" {
                return false
            }
            if StopLinesList.linesDisabled.index(of: departure.line) == nil {
                return true
            }
            return false
        }

        refreshTheme()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        tableView?.dg_removePullToRefresh()
    }

    func labelToImage(_ label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func toggleFavorite(_ sender: Any!) {
        if AppValues.favoritesStops.isEmpty {
            let array: [String:Stop] = [stop!.fullName: stop!]
            AppValues.fullNameFavoritesStops.append(stop!.fullName)
            AppValues.favoritesStops = array

            let encodedData = NSKeyedArchiver.archivedData(withRootObject: array)
            defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesStops.rawValue)
        } else {
            if (AppValues.fullNameFavoritesStops.index(of: stop!.fullName)) != nil {
                AppValues.favoritesStops.removeValue(forKey: stop!.fullName)
                AppValues.fullNameFavoritesStops.remove(at: AppValues.fullNameFavoritesStops.index(of: stop!.fullName)!)
            } else {
                AppValues.favoritesStops![stop!.fullName] = stop
                AppValues.fullNameFavoritesStops.append(stop!.fullName)
            }
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: AppValues.favoritesStops!)
            defaults.set(encodedData, forKey: UserDefaultsKeys.favoritesStops.rawValue)
        }

        if WCSession.isSupported() {
            do {
                var a: [String:[String:Any]] = [:]
                for (x, y) in AppValues.favoritesStops {
                    a[x] = y.toDictionnary()
                }
                var offlineDepartures: [String:String] = [:]
                var path = ""
                for (_, y) in AppValues.favoritesStops {
                    var json = JSON(data: "{}".data(using: String.Encoding.utf8)!)
                    var departuresArray: [String:String] = [:]
                    let dir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
                    path = dir.appendingPathComponent(y.stopCode + "departsSAM.json").absoluteString

                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try departuresArray["SAM"] = String(contentsOfFile: path)
                        } catch {
                            print("Reading of \(path) is failed")
                        }
                    }

                    path = dir.appendingPathComponent(y.stopCode + "departsDIM.json").absoluteString

                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try departuresArray["DIM"] = String(contentsOfFile: path)
                        } catch {
                            print("Reading of \(path) is failed")
                        }
                    }

                    path = dir.appendingPathComponent(y.stopCode + "departsLUN.json").absoluteString

                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try departuresArray["LUN"] = String(contentsOfFile: path)
                        } catch {
                            print("Reading of \(path) is failed")
                        }
                    }

                    json.dictionaryObject = departuresArray
                    offlineDepartures[y.stopCode] = json.rawString() ?? ""

                }
                try WatchSessionManager.sharedManager.updateApplicationContext([
                    "favoritesStops": NSKeyedArchiver.archivedData(withRootObject: a) as Any,
                    "offlineDepartures": offlineDepartures as Any])

            } catch {
                print("Update WatchConnectivity with application context failed")
            }
        }

        var barButtonsItems: [UIBarButtonItem] = []

        if AppValues.fullNameFavoritesStops.index(of: stop!.fullName) != nil {
            barButtonsItems.append(
                UIBarButtonItem(image: #imageLiteral(resourceName: "starNavbar"),
                                style: UIBarButtonItemStyle.done,
                                target: self,
                                action: #selector(self.toggleFavorite(_:))))
        } else {
            barButtonsItems.append(
                UIBarButtonItem(image: #imageLiteral(resourceName: "starEmptyNavbar"),
                                style: UIBarButtonItemStyle.done,
                                target: self,
                                action: #selector(self.toggleFavorite(_:))))
        }
        barButtonsItems.append(
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.done,
                            target: self,
                            action: #selector(self.refresh)))

        self.navigationItem.rightBarButtonItems = barButtonsItems
        guard let navController = self.splitViewController?.viewControllers[0] as? UINavigationController else {
            return
        }
        guard let arretTableViewController = navController.viewControllers[0] as? StopsTableViewController else {
            return
        }
        arretTableViewController.tableView.reloadData()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showLine" && departuresList[selectedIndexPath!.row].leftTime == "no more" {
            return false
        } else if offline && selectedIndexPath!.section == 2 {
            return false
        } else {
            return true
        }
    }

    func scheduleNotification(_ hour: String, before: Int, line: String, direction: String) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    let content = UNMutableNotificationContent()
                    if before == 0 {
                        content.title = "Départ immédiat !".localized
                        content.body = "Le tpg de la line ".localized + line + " en direction de ".localized + direction + " va partir immédiatement".localized
                    } else {
                        content.title = "Départ dans ".localized + String(before) + " minutes".localized
                        var text =  "Le tpg de la line ".localized
                        text += line
                        text += " en direction de ".localized
                        text += direction
                        text += " va partir dans ".localized
                        text += String(before)
                        text += " minutes".localized
                        content.body = text
                    }
                    content.categoryIdentifier = "departureNotifications"
                    content.userInfo = [:]
                    content.sound = UNNotificationSound.default()

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    var time = dateFormatter.date(from: hour)
                    time!.addTimeInterval(Double(before) * -60.0)
                    let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)

                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())

                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: Calendar.current.dateComponents([.year,
                                                                       .month,
                                                                       .day,
                                                                       .hour,
                                                                       .minute,
                                                                       .second],
                                                                      from: date!),
                        repeats: false)

                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in
                        DispatchQueue.main.sync {
                            if error == nil {
                                let okView = SCLAlertView()
                                if before == 0 {
                                    okView.showSuccess(
                                        "Vous serez notifié".localized,
                                        subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized,
                                        closeButtonTitle: "OK",
                                        duration: 10,
                                        feedbackType: .notificationSuccess)
                                } else {
                                    var texte =  "La notification à été enregistrée et sera affichée ".localized
                                    texte += String(before)
                                    texte += " minutes avant le départ.".localized
                                    okView.showSuccess(
                                        "Vous serez notifié".localized,
                                        subTitle: texte,
                                        closeButtonTitle: "OK",
                                        duration: 10,
                                        feedbackType: .notificationSuccess)
                                }
                            } else {
                                SCLAlertView().showError(
                                    "Impossible d'enregistrer la notification",
                                    subTitle: "L'erreur a été reportée au développeur. Merci de réessayer.",
                                    closeButtonTitle: "OK", duration: 30, feedbackType: .notificationError)
                            }
                        }
                    })
                } else {
                    SCLAlertView().showError(
                        "Notifications désactivées",
                        subTitle: "Merci d'activer les notifications dans les réglages",
                        closeButtonTitle: "OK",
                        duration: 30,
                        feedbackType: .notificationError)
                }
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            var time = dateFormatter.date(from: hour)
            time!.addTimeInterval(Double(before) * -60.0)
            let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)

            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())
            let reminder = UILocalNotification()
            reminder.fireDate = date
            reminder.soundName = UILocalNotificationDefaultSoundName
            if before == 0 {
                reminder.alertBody = "\("Le tpg de la line ".localized)\(line)\(" en direction de ".localized)\(direction)\(" va partir immédiatement".localized)"
            } else {
                var texte =  "Le tpg de la line ".localized
                texte += line
                texte += " en direction de ".localized
                texte += direction
                texte += " va partir dans ".localized
                texte += String(before)
                texte += " minutes".localized
                reminder.alertBody = texte
            }

            UIApplication.shared.scheduleLocalNotification(reminder)

            print("Firing at \(String(describing: now.hour)):\(now.minute!-before):\(String(describing: now.second))")

            let okView = SCLAlertView()
            if before == 0 {
                okView.showSuccess(
                    "Vous serez notifié".localized,
                    subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized,
                    closeButtonTitle: "OK", duration: 10, feedbackType: .notificationSuccess)
            } else {
                var texte =  "La notification à été enregistrée et sera affichée ".localized
                texte += String(before)
                texte += " minutes avant le départ.".localized
                okView.showSuccess("Vous serez notifié".localized, subTitle: texte, closeButtonTitle: "OK", duration: 10, feedbackType: .notificationSuccess)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLine" {
            if let thermometerViewController = (segue.destination) as? ThermometerTableViewController {
                thermometerViewController.departure = departuresList[(selectedIndexPath?.row)!]
            }
        } else if segue.identifier == "showAllDepartures" {
            let indexPath = selectedIndexPath ?? IndexPath(row: 0, section: 0)
            if let seeAllDeparturesViewController = (segue.destination) as? SeeAllDeparturesViewController {
                seeAllDeparturesViewController.stop = self.stop!
                seeAllDeparturesViewController.line = self.departuresList[indexPath.row].line
                seeAllDeparturesViewController.direction = self.departuresList[indexPath.row].direction
                seeAllDeparturesViewController.destinationCode = self.departuresList[indexPath.row].destinationCode
            }
        }
    }

    func refresh() {
        self.loading = true
        self.notDownloaded = false
        self.selectedIndexPath = nil
        self.tableView.reloadData()
        departuresList = []
        initialDeparturesList = []
        StopLinesList.linesList = []
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": stop!.stopCode])
            .responseJSON { response in
                if let data = response.result.value {
                    let departs = JSON(data)
                    FIRCrashMessage("Offline = false")
                    FIRCrashMessage("\(String(describing: departs.rawString()))")

                    for (_, subjson) in departs["departures"] {
                        if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                            self.initialDeparturesList.append(Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: .white,
                                lineBackgroundColor: .flatGray,

                                code: String(subjson["departureCode"].int ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                            ))
                        } else {
                            self.initialDeparturesList.append(Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: AppValues.linesColor[subjson["line"]["lineCode"].string!]!,
                                lineBackgroundColor: AppValues.linesBackgroundColor[subjson["line"]["lineCode"].string!]!,

                                code: String(subjson["departureCode"].int ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                            ))
                        }
                        if StopLinesList.linesList.index(of: subjson["line"]["lineCode"].string!) == nil {
                            StopLinesList.linesList.append(subjson["line"]["lineCode"].string!)
                        }
                    }

                    self.departuresList = self.initialDeparturesList.filter { (departure) -> Bool in
                        if StopLinesList.filterNoMore && departure.leftTime == "no more" {
                            return false
                        }
                        if StopLinesList.linesDisabled.index(of: departure.line) == nil {
                            return true
                        }
                        return false
                    }
                    self.offline = false

                    if self.departuresList.count == 0 {
                        self.noMoreTransport = true
                    } else {
                        self.noMoreTransport = false
                    }
                    self.loading = false
                    self.tableView.reloadData()
                    self.tableView.dg_stopLoading()
                } else {
                    FIRCrashMessage("Offline = true")
                    #if DEBUG
                        if let error = response.result.error {
                            let alert = SCLAlertView()
                            alert.showError("DEBUG", subTitle: "DEBUG - \(error.localizedDescription)", feedbackType: .impactMedium)
                        }
                    #endif
                    let day = Calendar.current.dateComponents([.weekday], from: Date())
                    var path: URL
                    let dir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
                    switch day.weekday! {
                    case 7:
                        path = dir.appendingPathComponent(self.stop!.stopCode + "departsSAM.json")
                        break
                    case 1:
                        path = dir.appendingPathComponent(self.stop!.stopCode + "departsDIM.json")
                        break
                    default:
                        path = dir.appendingPathComponent(self.stop!.stopCode + "departsLUN.json")

                        break
                    }

                    do {
                        let departuresJSONString = try NSString(contentsOf: path, encoding: String.Encoding.utf8.rawValue)

                        let departs = JSON(data: departuresJSONString.data(using: String.Encoding.utf8.rawValue)!)
                        for (_, subJson) in departs {
                            if AppValues.linesColor[subJson["ligne"].string!] != nil {
                                self.initialDeparturesList.append(Departures(
                                    line: subJson["ligne"].string!,
                                    direction: subJson["destination"].string!,
                                    destinationCode: "",
                                    lineColor: AppValues.linesColor[subJson["ligne"].string!]!,
                                    lineBackgroundColor: AppValues.linesBackgroundColor[subJson["ligne"].string!]!,
                                    code: nil,
                                    leftTime: "0",
                                    timestamp: subJson["timestamp"].string!
                                ))

                            } else {
                                self.initialDeparturesList.append(Departures(
                                    line: subJson["ligne"].string!,
                                    direction: subJson["destination"].string!,
                                    destinationCode: "",
                                    lineColor: .white,
                                    lineBackgroundColor: .flatGray,
                                    code: nil,
                                    leftTime: "0",
                                    timestamp: subJson["timestamp"].string!
                                ))
                            }
                            if StopLinesList.linesList.index(of: subJson["ligne"].string!) == nil {
                                StopLinesList.linesList.append(subJson["ligne"].string!)
                            }
                            self.initialDeparturesList.last?.calculerTempsRestant()
                        }
                        self.initialDeparturesList = self.initialDeparturesList.filter({ (departure) -> Bool in
                            if departure.leftTime != "-1" {
                                return true
                            }
                            return false
                        })
                        self.initialDeparturesList.sort(by: { (depart1, depart2) -> Bool in
                            guard let leftTime1 = Int(depart1.leftTime) else {
                                return false
                            }
                            guard let leftTime2 = Int(depart2.leftTime) else {
                                return false
                            }
                            if leftTime1 < leftTime2 {
                                return true
                            }
                            return false
                        })
                        self.departuresList = self.initialDeparturesList.filter({ (departure) -> Bool in
                            if StopLinesList.filterNoMore && departure.leftTime == "no more" {
                                return false
                            }
                            if StopLinesList.linesDisabled.index(of: departure.line) != nil {
                                return false
                            }
                            return true
                        })

                        self.departuresList.sort(by: { (depart1, depart2) -> Bool in
                            guard let leftTime1 = Int(depart1.leftTime) else {
                                return false
                            }
                            guard let leftTime2 = Int(depart2.leftTime) else {
                                return false
                            }
                            if leftTime1 < leftTime2 {
                                return true
                            }
                            return false
                        })

                        self.offline = true

                        if self.departuresList.count == 0 {
                            self.noMoreTransport = true
                        } else {
                            self.noMoreTransport = false
                        }
                        self.loading = false

                        self.tableView.reloadData()
                        self.tableView.dg_stopLoading()
                    } catch {
                        self.offline = true
                        self.departuresList = []
                        self.noMoreTransport = false
                        self.loading = false
                        self.notDownloaded = true
                        self.tableView.reloadData()
                        self.tableView.dg_stopLoading()
                    }
                }
        }
    }
}

extension DeparturesViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        if loading == true {
            return 1
        } else if offline || notDownloaded {
            return 3
        }
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true {
            return 1
        } else if offline && notDownloaded {
            return 1
        } else if offline && section == 0 {
            return 1
        } else if offline && section == 1 && noMoreTransport {
            return 1
        } else if !offline && section == 0 && noMoreTransport {
            return 1
        } else if (offline && section == 1) || (!offline && section == 0) {
            return 1
        } else {
            return departuresList.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndexPath == indexPath {
            return 176
        }
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (offline && indexPath.section == 2) || (!offline && indexPath.section == 1) {
            performSegue(withIdentifier: "showFilterDepartures", sender: self)
        } else if canSelect(indexPath: indexPath) {
            let previousIndexPath = selectedIndexPath
            if selectedIndexPath == indexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
            }
            if let previousIndexPath = previousIndexPath {
                tableView.reloadRows(at: [previousIndexPath, indexPath], with: .automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    func askForReminder() {
        guard let indexPath = selectedIndexPath else {
            return
        }
        let alertView = SCLAlertView()
        if self.departuresList[indexPath.row].leftTime == "0" {
            alertView.showWarning(
                "Le bus arrive".localized,
                subTitle: "Dépêchez vous, vous allez le rater !".localized,
                closeButtonTitle: "OK".localized,
                duration: 10,
                feedbackType: .notificationWarning)
        } else {
            alertView.addButton("A l'heure du départ".localized, action: { () -> Void in
                self.scheduleNotification(
                    self.departuresList[indexPath.row].timestamp,
                    before: 0,
                    line: self.departuresList[indexPath.row].line,
                    direction: self.departuresList[indexPath.row].direction)

            })
            if Int(self.departuresList[indexPath.row].leftTime)! > 5 {
                alertView.addButton("5 min avant le départ".localized, action: { () -> Void in
                    self.scheduleNotification(
                        self.departuresList[indexPath.row].timestamp,
                        before: 5,
                        line: self.departuresList[indexPath.row].line,
                        direction: self.departuresList[indexPath.row].direction)
                })
            }
            if Int(self.departuresList[indexPath.row].leftTime)! > 10 {
                alertView.addButton("10 min avant le départ".localized, action: { () -> Void in
                    self.scheduleNotification(
                        self.departuresList[indexPath.row].timestamp,
                        before: 10,
                        line: self.departuresList[indexPath.row].line,
                        direction: self.departuresList[indexPath.row].direction)
                })
            }
            alertView.addButton("Autre".localized, action: { () -> Void in
                alertView.hideView()
                let customValueAlert = SCLAlertView()
                let txt = customValueAlert.addTextField("Nombre de minutes".localized)
                txt.keyboardType = .numberPad
                txt.becomeFirstResponder()
                customValueAlert.addButton("Rappeler".localized, action: { () -> Void in
                    if Int(self.departuresList[indexPath.row].leftTime)! < Int(txt.text!)! {
                        customValueAlert.hideView()
                        SCLAlertView().showError("Il y a un problème".localized,
                                                 subTitle: "Merci de taper un nombre inférieur à la durée restante avant l'arrivée du tpg.".localized,
                                                 closeButtonTitle: "OK".localized,
                                                 duration: 10,
                                                 feedbackType: .notificationError)

                    } else {
                        self.scheduleNotification(self.departuresList[indexPath.row].timestamp, before: Int(txt.text!)!, line: self.departuresList[indexPath.row].line, direction: self.departuresList[indexPath.row].direction)
                        customValueAlert.hideView()
                    }
                })
                customValueAlert.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: #imageLiteral(resourceName: "clock").maskWithColor(color: .white))
            })
            alertView.showNotice("Rappeler".localized, subTitle: "Quand voulez-vous être notifié(e) ?".localized, closeButtonTitle: "Annuler".localized, circleIconImage: #imageLiteral(resourceName: "clock").maskWithColor(color: .white))
        }
    }

    func canSelect(indexPath: IndexPath) -> Bool! {
        if loading == true {
            return false
        } else if offline && notDownloaded {
            return false
        } else if offline && indexPath.section == 0 {
            return false
        } else if offline && indexPath.section == 1 && noMoreTransport {
            return false
        } else if !offline && indexPath.section == 0 && noMoreTransport {
            return false
        } else if departuresList.count == 0 {
            return false
        } else if departuresList[indexPath.row].leftTime == "no more" {
            return false
        } else if (offline && indexPath.section == 1 ) || (!offline && indexPath.section == 0) {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCellTableViewCell // swiftlint:disable:this force_cast

            cell.activityIndicator.stopAnimating()

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = .flatBlue
                cell.titleLabel?.textColor = .white
                cell.subTitleLabel?.textColor = .white
                cell.activityIndicator.color = .white
            } else {
                cell.backgroundColor = .white
                cell.titleLabel?.textColor = .flatBlue
                cell.subTitleLabel?.textColor = .flatBlue
                cell.activityIndicator.color = .flatBlue
            }
            cell.titleLabel?.text = "Chargement".localized
            cell.subTitleLabel?.text = "Merci de patienter".localized
            cell.accessoryView = nil

            cell.activityIndicator.startAnimating()

            return cell
        } else if indexPath.section == 0 && offline {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)

            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Mode offline".localized
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Les horaires peuvent être sujets à modification".localized
            cell.imageView?.image = #imageLiteral(resourceName: "globe").maskWithColor(color: AppValues.textColor)
            cell.accessoryView = nil
            return cell
        } else if offline && notDownloaded && indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)

            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Non téléchargé".localized
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Vous pouvez télécharger les départs dans les paramètres afin d'y avoir accès en mode hors-ligne.".localized
            cell.imageView?.image = #imageLiteral(resourceName: "cloudWarning").maskWithColor(color: AppValues.textColor)
            cell.accessoryView = nil
            return cell
        } else if offline && indexPath.section == 1 && noMoreTransport {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)

            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Service terminé".localized
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arrêt.".localized
            cell.imageView?.image = #imageLiteral(resourceName: "bus").maskWithColor(color: AppValues.textColor)
            cell.accessoryView = nil
            return cell
        } else if (offline && indexPath.section == 1) || (!offline && indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath) // swiftlint:disable:this force_cast

            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Filtrer".localized
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = #imageLiteral(resourceName: "filter").maskWithColor(color: AppValues.textColor)
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWithColor(color: AppValues.textColor))
            return cell
        } else if !offline && indexPath.section == 0 && noMoreTransport {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoArretCell", for: indexPath)

            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.textLabel?.text = "Service terminé".localized
            cell.detailTextLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.text = "Plus aucun départ n'est prévu pour la totalité des lignes desservants cet arrêt.".localized
            cell.imageView?.image = #imageLiteral(resourceName: "bus").maskWithColor(color: AppValues.textColor)
            cell.accessoryView = nil
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath) as! DepartureTableViewCell // swiftlint:disable:this force_cast

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = departuresList[indexPath.row].lineBackgroundColor
            } else {
                cell.backgroundColor = .white
            }

            var lineColor = AppValues.textColor

            if AppValues.primaryColor.contrast == .white {
                lineColor = departuresList[indexPath.row].lineColor
            } else {
                if departuresList[indexPath.row].lineBackgroundColor.contrast == .white {
                    lineColor = self.departuresList[indexPath.row].lineBackgroundColor
                } else {
                    lineColor = self.departuresList[indexPath.row].lineBackgroundColor.darken(percentage: 0.2)
                }
            }

            for imageView in cell.nextImages {
                imageView.image = UIImage(named: "next")?.maskWithColor(color: lineColor!)
            }
            cell.buttonReminder.setTitleColor(lineColor, for: .normal)
            cell.buttonReminder.addTarget(self, action: #selector(askForReminder), for: .touchUpInside)
            cell.buttonFollowTrack.setTitleColor(lineColor, for: .normal)
            cell.buttonSeeAllDepartures.setTitleColor(lineColor, for: .normal)
            cell.buttonReminder.setImage(#imageLiteral(resourceName: "bell").maskWithColor(color: lineColor!), for: .normal)
            cell.buttonFollowTrack.setImage(#imageLiteral(resourceName: "bus").maskWithColor(color: lineColor!), for: .normal)
            cell.buttonSeeAllDepartures.setImage(#imageLiteral(resourceName: "clockSmall").maskWithColor(color: lineColor!), for: .normal)

            FIRCrashMessage("Departure: \(departuresList[indexPath.row].describe())")

            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = departuresList[indexPath.row].line
            labelPictoLigne.textAlignment = .center
            labelPictoLigne.textColor = lineColor
            labelPictoLigne.layer.borderColor = lineColor!.cgColor
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.linePictogram.image = image
            cell.directionLabel.text = departuresList[indexPath.row].direction

            cell.directionLabel.textColor = lineColor
            cell.leftTimeLabel.textColor = lineColor

            if offline {
                cell.accessoryView = UIImageView(image: nil)

                if Int(departuresList[indexPath.row].leftTime)! >= 60 {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.date(from: self.departuresList[indexPath.row].timestamp)

                    cell.leftTimeLabel.text = DateFormatter.localizedString(
                        from: time!,
                        dateStyle: DateFormatter.Style.none,
                        timeStyle: DateFormatter.Style.short)
                } else if departuresList[indexPath.row].leftTime == "0" {
                    cell.leftTimeLabel.text = ""
                    cell.leftImage.image = #imageLiteral(resourceName: "bus").maskWithColor(color: lineColor!)
                } else {
                    cell.leftTimeLabel.text = departuresList[indexPath.row].leftTime + "'"
                    cell.leftImage.image = nil
                }
            } else {
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWithColor(color: lineColor!))

                if departuresList[indexPath.row].leftTime == "no more" {
                    cell.accessoryView = UIImageView(image: nil)
                    cell.leftTimeLabel.text = ""
                    cell.leftImage.image = #imageLiteral(resourceName: "cross").maskWithColor(color: lineColor!)
                } else if departuresList[indexPath.row].leftTime == "&gt;1h" {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    let time = dateFormatter.date(from: self.departuresList[indexPath.row].timestamp)
                    if let time = time {
                        cell.leftTimeLabel.text = DateFormatter.localizedString(
                            from: time,
                            dateStyle: DateFormatter.Style.none,
                            timeStyle: DateFormatter.Style.short)
                    } else {
                        cell.leftTimeLabel.text = ""
                        cell.leftImage.image = #imageLiteral(resourceName: "warning").maskWithColor(color: lineColor!)
                    }
                } else if departuresList[indexPath.row].leftTime == "0" {
                    cell.leftTimeLabel.text = ""
                    cell.leftImage.image = #imageLiteral(resourceName: "bus").maskWithColor(color: lineColor!)
                } else {
                    cell.leftTimeLabel.text = departuresList[indexPath.row].leftTime + "'"
                    cell.leftImage.image = nil
                }
            }

            if selectedIndexPath == indexPath {
                cell.backgroundColor = cell.backgroundColor?.darken(percentage: 0.01)
                cell.accessoryView = nil
            }

            return cell
        }
    }

    func showRoute() {
        recenterMap = true
        routeActivated = !routeActivated
        self.mapViewHeightConstraints.forEach({ (constraint) in
            if constraint.priority < 750 {
                constraint.priority = 751
            } else if constraint.priority > 750 {
                constraint.priority = 749
            }
            UIView.animate(withDuration: 0.5, animations: self.view.layoutIfNeeded)
        })
    }
}

extension DeparturesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }

        if loading == true {
            return nil
        } else if offline && notDownloaded {
            return nil
        } else if offline && indexPath.section == 0 {
            return nil
        } else if offline && indexPath.section == 1 && noMoreTransport {
            return nil
        } else if !offline && indexPath.section == 0 && noMoreTransport {
            return nil
        } else if departuresList.count == 0 {
            return nil
        } else if departuresList[indexPath.row].leftTime == "no more" {
            return nil
        } else if (offline && indexPath.section == 1 ) || (!offline && indexPath.section == 0) {
            return nil
        }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "thermometerTableViewController") as? ThermometerTableViewController else { return nil }

        detailVC.departure = departuresList[indexPath.row]
        previewingContext.sourceRect = cell.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

extension DeparturesViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let route = self.route else {
            return MKPolylineRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: route.polyline)

        renderer.lineWidth = 4

        if AppValues.primaryColor.contrast == .white {
            renderer.strokeColor = AppValues.primaryColor
        } else {
            renderer.strokeColor = AppValues.textColor
        }

        return renderer
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: stop!.location.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .walking

        let directions = MKDirections(request: request)

        directions.calculate {response, _ in
            guard let route = response?.routes.first else { return }

            self.route = route

            self.timeToGo = Int(userLocation.location!.distance(from: self.stop!.location) / 5000 * 60)
            self.routeArea = route.polyline.boundingMapRect
            self.mapViewHeightConstraints.forEach({ (constraint) in
                if constraint.priority < 750 {
                    constraint.priority = 751
                } else if constraint.priority > 750 {
                    constraint.priority = 749
                }
                UIView.animate(withDuration: 0.5, animations: self.view.layoutIfNeeded)
            })
        }
    }

    func centerMap() {
        guard let coordinate = self.coordinate else {
            return
        }
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        mapView.setRegion(region, animated: true)
    }
}
