//
//  SmartRemindersSettingsTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 05/04/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit

class SmartRemindersSettingsTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = Text.smartReminders
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
}
