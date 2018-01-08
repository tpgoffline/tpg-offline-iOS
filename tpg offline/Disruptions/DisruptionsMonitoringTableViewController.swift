//
//  DisruptionsMonitoringTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import Alamofire

class DisruptionsMonitoringTableViewController: UITableViewController {

    var disruptionMonitoringList: [DisruptionMonitoring] = []

    var requestStatus: RequestStatus = .loading {
        didSet {
            self.tableView.allowsSelection = requestStatus == .ok
            self.tableView.reloadData()

            if requestStatus == .error {
                let alertController = UIAlertController(title: "Sorry".localized,
                                                        message: "You need to be connected to internet to manage disruptions monitoring.".localized,
                                                        preferredStyle: .alert)
                let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
                    print("AEE")
                    self.navigationController?.popToRootViewController(animated: true)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    var lines: [String] {
        return disruptionMonitoringList.map({ $0.line }).uniqueElements.sorted(by: {
            if let a = Int($0), let b = Int($1) {
                return a < b
            } else { return $0 < $1 }})
    }

    var firstOpeningOfDisruptionsMonitoring: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [
            self.editButtonItem,
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addLineMonitoring)),
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"), style: .plain, target: self, action: #selector(self.reload), accessbilityLabel: "Reload")
        ]

        if App.apnsToken == "" {
            let alertController = UIAlertController(title: "Sorry".localized, message: "We need your devices's unique identifier to send you notifications, even if the app is closed (except if the device is off). Check if notifications and background app refresh are allowed.".localized, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }

        if firstOpeningOfDisruptionsMonitoring == true, App.apnsToken != "" {
            firstOpeningOfDisruptionsMonitoring = false
            let alertController = UIAlertController(title: "Disruptions monitoring".localized, message: "Here, you can choose when you want to monitor the lines you want. If a disruption occured during the monitoring period, we will send you a notification.".localized, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }

        title = "Monitoring".localized

        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }

        refreshControl = UIRefreshControl()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl!)
        }

        refreshControl?.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        ColorModeManager.shared.addColorModeDelegate(self)

        reload()
    }

    @objc func reload() {
        Alamofire.request("https://tpgoffline-apns.alwaysdata.net/status/\(App.apnsToken)").responseData { (response) in
            if let data = response.data {
                let jsonDecoder = JSONDecoder()

                do {
                    let json = try jsonDecoder.decode([DisruptionMonitoring].self, from: data)
                    self.disruptionMonitoringList = json
                    self.requestStatus = json.count == 0 ? .noResults : .ok
                } catch {
                    self.requestStatus = .error
                    return
                }
            } else {
                self.requestStatus = .error
            }
            self.refreshControl?.endRefreshing()
        }
    }

    @objc func addLineMonitoring() {
        performSegue(withIdentifier: "addLineMonitoring", sender: self)
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.reload()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return lines.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disruptionMonitoringList.filter({ $0.line == lines[section] }).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "disruptionsMonitoringCell", for: indexPath)
            as? DisruptionsMonitoringTableViewCell else {
            return UITableViewCell()
        }

        cell.disruptionMonitoring = disruptionMonitoringList.filter({ $0.line == lines[indexPath.section] })[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.requestStatus == .loading {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
            headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            headerCell?.textLabel?.text = ""
            return headerCell
        } else if self.requestStatus == any(of: .error, .noResults) {
            return nil
        }
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        let color = App.color(for: lines[section])
        headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
        headerCell?.textLabel?.text = String(format: "Line %@".localized, lines[section])
        headerCell?.textLabel?.textColor = App.darkMode ? color : color.contrast

        return headerCell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let row = tableView.cellForRow(at: indexPath) as? DisruptionsMonitoringTableViewCell else { return }
            guard let disruptionMonitoring = row.disruptionMonitoring else { return }
            if let position = self.disruptionMonitoringList.index(of: disruptionMonitoring) {

                Alamofire.request("https://tpgoffline-apns.alwaysdata.net/remove/\(App.apnsToken)/\(disruptionMonitoring.line)/\(disruptionMonitoring.fromHour)/\(disruptionMonitoring.toHour)/\(disruptionMonitoring.days)").responseString(completionHandler: { (response) in
                    if let string = response.result.value, string == "1" {
                        self.disruptionMonitoringList.remove(at: position)
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class DisruptionsMonitoringTableViewCell: UITableViewCell {
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!

    var disruptionMonitoring: DisruptionMonitoring? {
        didSet {
            guard let disruptionMonitoring = self.disruptionMonitoring else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            var time = dateFormatter.date(from: disruptionMonitoring.fromHour)
            let fromHour = DateFormatter.localizedString(
                    from: time ?? Date(),
                    dateStyle: DateFormatter.Style.none,
                    timeStyle: DateFormatter.Style.short)
            time = dateFormatter.date(from: disruptionMonitoring.toHour)
            let toHour = DateFormatter.localizedString(
                from: time ?? Date(),
                dateStyle: DateFormatter.Style.none,
                timeStyle: DateFormatter.Style.short)
            self.hoursLabel.text = "\(fromHour) - \(toHour)"

            let daysI = self.disruptionMonitoring?.days.split(separator: ":").map({ Int($0) ?? -1 }) ?? []
            var days: [String] = []
            for x in daysI {
                switch x {
                case 0:
                    days.append("Monday".localized)
                case 1:
                    days.append("Tuesday".localized)
                case 2:
                    days.append("Wednesday".localized)
                case 3:
                    days.append("Thursday".localized)
                case 4:
                    days.append("Friday".localized)
                case 5:
                    days.append("Saturday".localized)
                case 6:
                    days.append("Sunday".localized)
                default:
                    print("I don't know this day")
                }
            }
            self.daysLabel.text = days.joined(separator: " - ")
            let selectedView = UIView()
            selectedView.backgroundColor = .white

            if App.darkMode {
                self.backgroundColor = App.cellBackgroundColor
                self.hoursLabel.textColor = App.textColor
                self.daysLabel.textColor = App.textColor
                selectedView.backgroundColor = .black
            }
            self.selectedBackgroundView = selectedView
        }
    }
}
