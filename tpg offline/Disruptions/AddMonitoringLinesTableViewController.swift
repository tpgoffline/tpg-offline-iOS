//
//  AddMonitoringLinesTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

struct AddMonitoring {
  static var lines: [String] = []
  static var fromHour: String = ""
  static var toHour: String = ""
  static var days: String = ""
}

class AddMonitoringLinesTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Lines".localized

    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return App.lines.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell =
      tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath)
        as? LineTableViewControllerRow
      else { return UITableViewCell() }

    cell.line = App.lines[indexPath.row]
    if AddMonitoring.lines.index(of: App.lines[indexPath.row].line) != nil {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }

    return cell
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    if let index = AddMonitoring.lines.index(of: App.lines[indexPath.row].line) {
      AddMonitoring.lines.remove(at: index)
      guard let cell = tableView.cellForRow(at: indexPath)
        as? LineTableViewControllerRow
        else { return }
      cell.accessoryType = .none
    } else {
      AddMonitoring.lines.append(App.lines[indexPath.row].line)
      guard let cell = tableView.cellForRow(at: indexPath)
        as? LineTableViewControllerRow
        else { return }
      cell.accessoryType = .checkmark
    }
  }

}
