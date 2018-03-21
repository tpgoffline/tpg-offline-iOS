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
        title = "Add new".localized

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
        }
        AddMonitoring.days = selectedRows.joined(separator: ":")
        Alamofire.request("https://tpgoffline-apns.alwaysdata.net/add/\(App.apnsToken)/\(AddMonitoring.line)/\(Locale.current.languageCode ?? "en")/\(AddMonitoring.fromHour)/\(AddMonitoring.toHour)/\(AddMonitoring.days)").responseString { (response) in
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
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

        cell.textLabel?.textColor = App.textColor
        cell.backgroundColor = App.cellBackgroundColor
        let selectedView = UIView()
        selectedView.backgroundColor = App.darkMode ? .black : .white
        cell.selectedBackgroundView = selectedView
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.selectedRows.index(of: "\(indexPath.row)") {
            self.selectedRows.remove(at: index)
        } else {
            self.selectedRows.append("\(indexPath.row)")
        }
        self.tableView.reloadData()
    }
}
