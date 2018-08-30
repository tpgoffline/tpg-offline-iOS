//
//  DayPicketViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
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
    title = Text.days

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
      let alertController = UIAlertController(title: Text.waitAMinute,
                                              message: Text.youForgotToAddDays,
                                              preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: Text.ok,
                                              style: .default,
                                              handler: nil))
      self.present(alertController, animated: true, completion: nil)
      return
    }
    AddMonitoring.days = selectedRows.joined(separator: ":")
    var parameters: Parameters = [
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
    Alamofire
      .request(URL.monitoring, method: .post, parameters: parameters)
      .responseString { (response) in
      if let string = response.result.value, string == "1" {
        guard let vController =
          self.navigationController?.viewControllers[1] else {
          self.navigationController?.popToRootViewController(animated: true)
          return
        }
        self.navigationController?.popToViewController(vController, animated: true)
      } else {
        let alertController = UIAlertController(title: Text.error,
                                                message: Text.errorNoInternet,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Text.ok,
                                                style: .default,
                                                handler: nil))
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

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 2 : 7
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
    if indexPath.section == 0 {
      switch indexPath.row {
      case 0:
        cell.textLabel?.text = Text.weekdays
        if ["0", "1", "2", "3", "4"].compactMap({
          self.selectedRows.contains($0)
        }).contains(false) {
          cell.accessoryType = .none
        } else {
          cell.accessoryType = .checkmark
        }
      case 1:
        cell.textLabel?.text = Text.weekend
        if self.selectedRows.index(of: "5") != nil,
          self.selectedRows.index(of: "6") != nil {
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
        cell.textLabel?.text = Text.monday
      case 1:
        cell.textLabel?.text = Text.tuesday
      case 2:
        cell.textLabel?.text = Text.wednesday
      case 3:
        cell.textLabel?.text = Text.thursday
      case 4:
        cell.textLabel?.text = Text.friday
      case 5:
        cell.textLabel?.text = Text.saturday
      case 6:
        cell.textLabel?.text = Text.sunday
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
        if self.selectedRows.index(of: "0") != nil,
          self.selectedRows.index(of: "1") != nil,
          self.selectedRows.index(of: "2") != nil,
          self.selectedRows.index(of: "3") != nil,
          self.selectedRows.index(of: "4") != nil {
          if let index = self.selectedRows.index(of: "0") {
            self.selectedRows.remove(at: index)
          }
          if let index = self.selectedRows.index(of: "1") {
            self.selectedRows.remove(at: index)
          }
          if let index = self.selectedRows.index(of: "2") {
            self.selectedRows.remove(at: index)
          }
          if let index = self.selectedRows.index(of: "3") {
            self.selectedRows.remove(at: index)
          }
          if let index = self.selectedRows.index(of: "4") {
            self.selectedRows.remove(at: index)
          }
        } else {
          if self.selectedRows.index(of: "0") == nil {
            self.selectedRows.append("0")
          }
          if self.selectedRows.index(of: "1") == nil {
            self.selectedRows.append("1")
          }
          if self.selectedRows.index(of: "2") == nil {
            self.selectedRows.append("2")
          }
          if self.selectedRows.index(of: "3") == nil {
            self.selectedRows.append("3")
          }
          if self.selectedRows.index(of: "4") == nil {
            self.selectedRows.append("4")
          }
        }
      } else {
        if self.selectedRows.index(of: "5") != nil,
          self.selectedRows.index(of: "6") != nil {
          if let index = self.selectedRows.index(of: "5") {
            self.selectedRows.remove(at: index)
          }
          if let index = self.selectedRows.index(of: "6") {
            self.selectedRows.remove(at: index)
          }
        } else {
          if self.selectedRows.index(of: "5") == nil {
            self.selectedRows.append("5")
          }
          if self.selectedRows.index(of: "6") == nil {
            self.selectedRows.append("6")
          }
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

  func tableView(_ tableView: UITableView,
                 titleForHeaderInSection section: Int) -> String? {
    return [Text.general, Text.specific][section]
  }
}
