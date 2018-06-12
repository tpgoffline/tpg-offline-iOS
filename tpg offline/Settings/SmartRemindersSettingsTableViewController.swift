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

        title = "Smart Reminders".localized
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = "Activated".localized
            let lightSwitch = UISwitch(frame: CGRect.zero) as UISwitch
            lightSwitch.isOn = App.smartReminders
            lightSwitch.addTarget(self, action: #selector(self.toggleStatus), for: .valueChanged)
            cell.accessoryView = lightSwitch
        } else {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "Smart reminders are departures reminders that, unlike standard reminders, take into account traffic variations and bus delays.\rThis feature requires an Internet connection to work, so it will not be offered in offline mode, and you can disabled it if you want in online mode.".localized
        }

        return cell
    }

    @objc func toggleStatus() {
        App.disableForceSmartReminders = true
        App.smartReminders = !App.smartReminders
        self.tableView.reloadData()
        if !App.smartReminders {
            let alert = UIAlertController(title: "Warning!".localized, message: "Deactivating Smart Reminders does not remove existing Smart Reminders. Use the Pending notifications section to remove them.".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (_) in
                App.smartReminders = !App.smartReminders
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "OK, deactivate Smart Reminders".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
