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
    case processing
    case error
}

class SettingsTableViewController: UITableViewController {

    var settings: [Setting] = []
    var offlineDeparturesStatus: OfflineDeparturesStatus = .notDownloading {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]

        self.settings.append(Setting("Update departures".localized, icon: #imageLiteral(resourceName: "download"), action: { (_) in
            self.updateDepartures()
        }))
        self.settings.append(Setting("Credits".localized, icon: #imageLiteral(resourceName: "crows"), action: { (_) in
            self.performSegue(withIdentifier: "showCredits", sender: self)
        }))
        self.settings.append(Setting("Give your feedback !".localized, icon: #imageLiteral(resourceName: "megaphone"), action: { (_) in
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self

            mailComposerVC.setToRecipients(["support@asmartcode.com"])
            mailComposerVC.setSubject("tpg offline".localized)
            mailComposerVC.setMessageBody("", isHTML: false)

            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        }))
        self.settings.append(Setting("Github webpage".localized, icon: #imageLiteral(resourceName: "github"), action: { (_) in
            let vc = SFSafariViewController(url: URL(string: "https://github.com/RemyDCF/tpg-offline")!, entersReaderIfAvailable: false)
            vc.delegate = self

            self.present(vc, animated: true)
        }))
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
        if setting.title == "Update departures".localized {
            switch self.offlineDeparturesStatus {
            case .notDownloading:
                cell.detailTextLabel?.text = ""
            case .error:
                cell.detailTextLabel?.text = "Error - Departures not downloaded".localized
            case .downloading:
                cell.detailTextLabel?.text = "Downloading".localized
            case .processing:
                cell.detailTextLabel?.text = "Processing".localized
            }
        }
        cell.imageView?.image = setting.icon.maskWith(color: App.textColor)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = self.settings[indexPath.row]
        setting.action(setting)
    }

    func updateDepartures() {
        self.offlineDeparturesStatus = .downloading
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/departuresV13.json").responseJSON { (response) in
            if let data = response.result.value as? [String: String] {
                self.offlineDeparturesStatus = .processing
                var index = 0
                for (key, value) in data {
                    DispatchQueue.main.async {
                        var fileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0])
                        fileURL.appendPathComponent(key)

                        do {
                            try value.write(to: fileURL, atomically: true, encoding: .utf8)
                        } catch (let error) {
                            print(error)
                        }
                        index += 1
                        //print(index)
                        if index == data.count {
                            self.offlineDeparturesStatus = .notDownloading
                        }
                    }
                }
            } else {
                self.offlineDeparturesStatus = .error
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
