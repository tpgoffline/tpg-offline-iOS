//
//  SettingsTableViewController.swift
//  tpg offline
//
//  Created by Remy on 16/08/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import MessageUI

class SettingsTableViewController: UITableViewController {

    var settings: [[Setting]] = []
    var titles = [
        "Notifications".localized,
        "Application".localized,
        "The project".localized
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            version != UserDefaults.standard.string(forKey: "lastVersion") && UserDefaults.standard.string(forKey: "lastVersion") != nil {
            self.performSegue(withIdentifier: "showNewFeatures", sender: self)
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]

        // Notifications
        self.settings.append([
            Setting("Pending notifications".localized, icon: #imageLiteral(resourceName: "cel-bell"), action: { (_) in
                self.performSegue(withIdentifier: "showPendingNotifications", sender: self)
            }),
            Setting("Smart Reminders".localized, icon: #imageLiteral(resourceName: "alarm"), action: { (_) in
                self.performSegue(withIdentifier: "showSmartReminders", sender: self)
            })
            ])

        // Application
        self.settings.append([
            Setting("Default tab on startup".localized, icon: #imageLiteral(resourceName: "menuRounded"), action: { (_) in
                self.performSegue(withIdentifier: "showDefaultTab", sender: self)
            }),
            Setting("Reorder stops view".localized, icon: #imageLiteral(resourceName: "reorder"), action: { (_) in
                self.performSegue(withIdentifier: "showReorderStopsView", sender: self)
            }),
            Setting("Update departures".localized, icon: #imageLiteral(resourceName: "download"), action: { (_) in
                App.log("Settings: Update Departures")
                self.performSegue(withIdentifier: "showUpdateDepartures", sender: self)
            }),
            Setting("Dark Mode".localized, icon: #imageLiteral(resourceName: "moon"), action: { (_) in
                self.performSegue(withIdentifier: "showDarkMode", sender: self)
            }),
            Setting("Privacy".localized, icon: #imageLiteral(resourceName: "circuit"), action: { (_) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            ])

        // The project
        self.settings.append([
            Setting("Give your feedback !".localized, icon: #imageLiteral(resourceName: "megaphone"), action: { ( _ ) in
                App.log("Settings: Give feedback")
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self

                mailComposerVC.setToRecipients(["helloworld@asmartcode.com"])
                mailComposerVC.setSubject("tpg offline".localized)
                mailComposerVC.setMessageBody("", isHTML: false)

                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposerVC, animated: true, completion: nil)
                }
            }),
            Setting("Last features".localized, icon: #imageLiteral(resourceName: "flag"), action: { (_) in
                self.performSegue(withIdentifier: "showNewFeatures", sender: self)
            }),
            Setting("Credits".localized, icon: #imageLiteral(resourceName: "crows"), action: { (_) in
                self.performSegue(withIdentifier: "showCredits", sender: self)
            }),
            Setting("Github webpage".localized, icon: #imageLiteral(resourceName: "github"), action: { (_) in
                let vc = SFSafariViewController(url: URL(string: "https://github.com/tpgoffline/tpg-offline-iOS")!, entersReaderIfAvailable: false)
                if App.darkMode, #available(iOS 10.0, *) {
                    vc.preferredBarTintColor = .black
                }
                vc.delegate = self

                self.present(vc, animated: true)
            })
            ])

        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.separatorColor = App.separatorColor
        }

        ColorModeManager.shared.addColorModeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        let setting = self.settings[indexPath.section][indexPath.row]

        cell.textLabel?.text = setting.title
        cell.textLabel?.textColor = App.textColor
        cell.detailTextLabel?.text = ""
        cell.detailTextLabel?.textColor = App.textColor
        cell.backgroundColor = App.cellBackgroundColor
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = setting.icon.maskWith(color: App.textColor)

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let setting = self.settings[indexPath.section][indexPath.row]
        setting.action(setting)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return (section + 1) == tableView.numberOfSections ? String(format: "tpg offline, version %@".localized, version) : nil
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsTableViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
