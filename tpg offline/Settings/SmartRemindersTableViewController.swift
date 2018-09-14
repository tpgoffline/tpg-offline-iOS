//
//  SmartRemindersSettingsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 05/04/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class SmartRemindersTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = Text.smartReminders
    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.separatorColor = App.separatorColor
    }

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    if indexPath.section == 0 {
      cell.textLabel?.text = Text.activated
      let lightSwitch = UISwitch(frame: CGRect.zero) as UISwitch
      lightSwitch.isOn = App.smartReminders
      lightSwitch.addTarget(self,
                            action: #selector(self.toggleStatus),
                            for: .valueChanged)
      cell.accessoryView = lightSwitch
    } else {
      cell.textLabel?.numberOfLines = 0
      cell.textLabel?.text = Text.smartRemindersDescription
    }

    cell.backgroundColor = App.cellBackgroundColor
    cell.textLabel?.textColor = App.textColor
    if App.darkMode {
      let selectedView = UIView()
      selectedView.backgroundColor = .black
      cell.selectedBackgroundView = selectedView
    } else {
      let selectedView = UIView()
      selectedView.backgroundColor = UIColor.white.darken(by: 0.1)
      cell.selectedBackgroundView = selectedView
    }

    return cell
  }

  @objc func toggleStatus() {
    App.disableForceSmartReminders = true
    App.smartReminders = !App.smartReminders
    self.tableView.reloadData()
    if !App.smartReminders {
      let alert = UIAlertController(title: Text.warning,
                                    message: Text.deactivateSmartRemindersMessage,
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: Text.cancel,
                                    style: .cancel,
                                    handler: { (_) in
        App.smartReminders = !App.smartReminders
        self.tableView.reloadData()
      }))
      alert.addAction(UIAlertAction(title: Text.continue,
                                    style: .default,
                                    handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}
