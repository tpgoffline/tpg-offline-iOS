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

enum OfflineDeparturesStatus {
    case notDownloading
    case downloading
    case processing(Int, Int)
    case error
}

class SettingsTableViewController: UITableViewController {

    var settings: [Setting] = []
    var offlineDeparturesStatus: OfflineDeparturesStatus = .notDownloading {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            version != UserDefaults.standard.string(forKey: "lastVersion") {
            self.performSegue(withIdentifier: "showNewFeatures", sender: self)
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]

        self.settings.append(Setting("Default tab on startup".localized, icon: #imageLiteral(resourceName: "menuRounded"), action: { (_) in
            self.performSegue(withIdentifier: "showDefaultTab", sender: self)
        }))
        self.settings.append(Setting("Update departures".localized, icon: #imageLiteral(resourceName: "download"), action: { (_) in
            App.log(string: "Settings: Update Departures")
            self.updateDepartures()
        }))
        self.settings.append(Setting("Credits".localized, icon: #imageLiteral(resourceName: "crows"), action: { (_) in
            self.performSegue(withIdentifier: "showCredits", sender: self)
        }))
        self.settings.append(Setting("Privacy".localized, icon: #imageLiteral(resourceName: "circuit"), action: { (_) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.settings.append(Setting("Last features".localized, icon: #imageLiteral(resourceName: "flag"), action: { (_) in
            self.performSegue(withIdentifier: "showNewFeatures", sender: self)
        }))
        self.settings.append(Setting("Dark Mode".localized, icon: #imageLiteral(resourceName: "moon"), action: { (_) in
            self.darkMode()
        }))
        self.settings.append(Setting("Give your feedback !".localized, icon: #imageLiteral(resourceName: "megaphone"), action: { ( _ ) in
            App.log(string: "Settings: Give feedback")
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self

            mailComposerVC.setToRecipients(["helloworld@asmartcode.com"])
            mailComposerVC.setSubject("tpg offline".localized)
            mailComposerVC.setMessageBody("", isHTML: false)

            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        }))
        self.settings.append(Setting("Github webpage".localized, icon: #imageLiteral(resourceName: "github"), action: { (_) in
            let vc = SFSafariViewController(url: URL(string: "https://github.com/RemyDCF/tpg-offline")!, entersReaderIfAvailable: false)
            if App.darkMode, #available(iOS 10.0, *) {
                vc.preferredBarTintColor = .black
            }
            vc.delegate = self

            self.present(vc, animated: true)
        }))

        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.separatorColor = App.separatorColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        let setting = self.settings[indexPath.row]

        cell.textLabel?.text = setting.title
        cell.textLabel?.textColor = App.textColor
        cell.detailTextLabel?.text = ""
        cell.detailTextLabel?.textColor = App.textColor
        cell.backgroundColor = App.cellBackgroundColor
        if setting.title == "Update departures".localized {
            switch self.offlineDeparturesStatus {
            case .notDownloading:
                cell.detailTextLabel?.text = UserDefaults.standard.bool(forKey: "offlineDeparturesUpdateAvailable") ?
                    "Update available".localized : ""
            case .error:
                cell.detailTextLabel?.text = "Error - Departures not downloaded".localized
            case .downloading:
                cell.detailTextLabel?.text = "Downloading".localized
            case .processing(let done, let total):
                cell.detailTextLabel?.text = String(format: "Processing %@/%@".localized, "\(done)", "\(total)")
            }
        }
        if setting.title == "Dark Mode".localized {
            let lightSwitch = UISwitch(frame: CGRect.zero) as UISwitch
            lightSwitch.isOn = UserDefaults.standard.bool(forKey: "darkMode")
            lightSwitch.addTarget(self, action: #selector(self.darkMode), for: .valueChanged)
            cell.accessoryView = lightSwitch
            if UserDefaults.standard.bool(forKey: "darkMode") != App.darkMode {
                cell.detailTextLabel?.text = "App restart needed".localized
            }
        }
        cell.imageView?.image = setting.icon.maskWith(color: App.textColor)

        if App.darkMode {
            let selectedView = UIView()
            selectedView.backgroundColor = .black
            cell.selectedBackgroundView = selectedView
        }

        return cell
    }

    @objc func darkMode() {
        UserDefaults.standard.set(!(UserDefaults.standard.bool(forKey: "darkMode")), forKey: "darkMode")
        self.tableView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let setting = self.settings[indexPath.row]
        setting.action(setting)
    }

    func updateDepartures() {
        self.offlineDeparturesStatus = .downloading
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json").responseJSON { (response) in
            if let data = response.result.value as? [String: String] {
                self.offlineDeparturesStatus = .processing(0, data.count)
                var index: UInt = 0

                let source = DispatchSource.makeUserDataAddSource(queue: .main)
                source.setEventHandler { [unowned self] in
                    index += source.data
                    self.offlineDeparturesStatus = .processing(Int(index), data.count)
                    print(index)
                    if index == data.count {
                        self.offlineDeparturesStatus = .notDownloading
                    }
                }
                source.resume()
                for (key, value) in data {
                    DispatchQueue.global(qos: .utility).async {
                        var fileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0])
                        fileURL.appendPathComponent(key)
                        do {
                            try value.write(to: fileURL, atomically: true, encoding: .utf8)
                        } catch let error {
                            print(error)
                        }
                        source.add(data: 1)
                    }
                }
            } else {
                self.offlineDeparturesStatus = .error
            }
        }
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json.md5").responseString { (response) in
            if let updatedMD5 = response.result.value {
                UserDefaults.standard.set(updatedMD5, forKey: "departures.json.md5")
                UserDefaults.standard.set(false, forKey: "offlineDeparturesUpdateAvailable")
                UserDefaults.standard.set(false, forKey: "remindUpdate")
            }
        }
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
