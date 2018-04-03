//
//  DayPicketViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import Alamofire

class DayPickerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var saveButton: UIButton!

    var selectedRows: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Days".localized

        tableView.separatorColor = App.separatorColor
        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.buttonBackgroundView.backgroundColor = App.cellBackgroundColor
            self.saveButton.backgroundColor = .black
            self.saveButton.setTitleColor(App.textColor, for: .normal)
        }

        ColorModeManager.shared.addColorModeDelegate(self)
    }

    @IBAction func save() {
        if selectedRows.isEmpty {
            let alertController = UIAlertController(title: "Wait a minute...".localized, message: "You forgot to add some days...".localized, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        AddMonitoring.days = selectedRows.joined(separator: ":")
        var parameters: Parameters = [
            "device": App.apnsToken,
            "lines": AddMonitoring.lines.joined(separator: ":"),
            "language": Locale.current.languageCode ?? "en",
            "fromHour": AddMonitoring.fromHour,
            "toHour": AddMonitoring.toHour,
            "days": AddMonitoring.days,
            "sandbox": false
        ]
        #if DEBUG
        parameters["sandbox"] = true
        #endif
        Alamofire.request("https://tpgoffline-apns.alwaysdata.net/add", method: .post, parameters: parameters).responseString { (response) in
            if let string = response.result.value, string == "1" {
                guard let viewController = self.navigationController?.viewControllers[1] else {
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
                self.navigationController?.popToViewController(viewController, animated: true)
            } else {
                let alertController = UIAlertController(title: "Error".localized, message: "Sorry, but we were not able to add your monitoring request. Are you sure you are connected to internet?".localized, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    override func colorModeDidUpdated() {
        self.tableView.backgroundColor = App.darkMode ? .black : .white
        self.buttonBackgroundView.backgroundColor = App.cellBackgroundColor
        self.saveButton.backgroundColor = App.darkMode ? .black : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        self.saveButton.setTitleColor(.white, for: .normal)
        self.tableView.reloadData()
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }
}

extension DayPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Weekdays".localized
                if self.selectedRows.index(of: "0") != nil, self.selectedRows.index(of: "1") != nil,
                    self.selectedRows.index(of: "2") != nil, self.selectedRows.index(of: "3") != nil,
                    self.selectedRows.index(of: "4") != nil {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            case 1:
                cell.textLabel?.text = "Weekend".localized
                if self.selectedRows.index(of: "5") != nil, self.selectedRows.index(of: "6") != nil {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            default:
                print("I don't know this day")
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Monday".localized
            case 1:
                cell.textLabel?.text = "Tuesday".localized
            case 2:
                cell.textLabel?.text = "Wednesday".localized
            case 3:
                cell.textLabel?.text = "Thursday".localized
            case 4:
                cell.textLabel?.text = "Friday".localized
            case 5:
                cell.textLabel?.text = "Saturday".localized
            case 6:
                cell.textLabel?.text = "Sunday".localized
            default:
                print("I don't know this day")
            }
            if self.selectedRows.index(of: "\(indexPath.row)") != nil {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        cell.textLabel?.textColor = App.textColor
        cell.backgroundColor = App.cellBackgroundColor
        let selectedView = UIView()
        selectedView.backgroundColor = App.darkMode ? .black : .white
        cell.selectedBackgroundView = selectedView
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.selectedRows.index(of: "0") != nil, self.selectedRows.index(of: "1") != nil,
                    self.selectedRows.index(of: "2") != nil, self.selectedRows.index(of: "3") != nil,
                    self.selectedRows.index(of: "4") != nil {
                    if let index = self.selectedRows.index(of: "0") { self.selectedRows.remove(at: index) }
                    if let index = self.selectedRows.index(of: "1") { self.selectedRows.remove(at: index) }
                    if let index = self.selectedRows.index(of: "2") { self.selectedRows.remove(at: index) }
                    if let index = self.selectedRows.index(of: "3") { self.selectedRows.remove(at: index) }
                    if let index = self.selectedRows.index(of: "4") { self.selectedRows.remove(at: index) }
                } else {
                    if self.selectedRows.index(of: "0") == nil { self.selectedRows.append("0") }
                    if self.selectedRows.index(of: "1") == nil { self.selectedRows.append("1") }
                    if self.selectedRows.index(of: "2") == nil { self.selectedRows.append("2") }
                    if self.selectedRows.index(of: "3") == nil { self.selectedRows.append("3") }
                    if self.selectedRows.index(of: "4") == nil { self.selectedRows.append("4") }
                }
            } else {
                if self.selectedRows.index(of: "5") != nil, self.selectedRows.index(of: "6") != nil {
                    if let index = self.selectedRows.index(of: "5") { self.selectedRows.remove(at: index) }
                    if let index = self.selectedRows.index(of: "6") { self.selectedRows.remove(at: index) }
                } else {
                    if self.selectedRows.index(of: "5") == nil { self.selectedRows.append("5") }
                    if self.selectedRows.index(of: "6") == nil { self.selectedRows.append("6") }
                }
            }
        } else {
            if let index = self.selectedRows.index(of: "\(indexPath.row)") {
                self.selectedRows.remove(at: index)
            } else {
                self.selectedRows.append("\(indexPath.row)")
            }
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["General".localized, "Specific".localized][section]
    }
}
