//
//  SettingsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/08/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import MessageUI
#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

class SettingsTableViewController: UITableViewController {

  var settings: [[Setting]] = []
  var titles = [
    Text.notifications,
    Text.application,
    Text.project
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
      navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.foregroundColor: App.textColor]
    }

    if let version =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
      version != UserDefaults.standard.string(forKey: "lastVersion"),
      UserDefaults.standard.string(forKey: "lastVersion") != nil {
      self.performSegue(withIdentifier: "showNewFeatures", sender: self)
    }

    navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedString.Key.foregroundColor: App.textColor]

    // Notifications
    self.settings.append([
      Setting(Text.pendingNotifications, icon: #imageLiteral(resourceName: "cel-bell"), action: { (_) in
        self.performSegue(withIdentifier: "showPendingNotifications", sender: self)
      }),
      Setting(Text.smartReminders, icon: #imageLiteral(resourceName: "alarm"), action: { (_) in
        self.performSegue(withIdentifier: "showSmartReminders", sender: self)
      })
      ])

    // Application
    self.settings.append([
      Setting(Text.defaultTabOnStartup, icon: #imageLiteral(resourceName: "menuRounded"), action: { (_) in
        self.performSegue(withIdentifier: "showDefaultTab", sender: self)
      }),
      Setting(Text.reorderStops, icon: #imageLiteral(resourceName: "reorder"), action: { (_) in
        self.performSegue(withIdentifier: "showReorderStopsView", sender: self)
      }),
      Setting(Text.updateOfflineData, icon: #imageLiteral(resourceName: "download"), action: { (_) in
        App.log("Settings: Update Departures")
        self.performSegue(withIdentifier: "showUpdateDepartures", sender: self)
      }),
      Setting(Text.darkMode, icon: #imageLiteral(resourceName: "moon"), action: { (_) in
        self.performSegue(withIdentifier: "showDarkMode", sender: self)
      }),
      Setting(Text.privacy, icon: #imageLiteral(resourceName: "circuit"), action: { (_) in
        self.performSegue(withIdentifier: "showPrivacy", sender: self)
      })
      ])

    #if !arch(i386) && !arch(x86_64)
    self.settings[1].append(Setting(Text.connectWifi,
                                    icon: #imageLiteral(resourceName: "wifi"),
                                    action: { (_) in
      if #available(iOS 11.0, *) {
        let configuration = NEHotspotConfiguration(ssid: "tpg-freeWiFi")
        configuration.joinOnce = false
        NEHotspotConfigurationManager.shared.apply(configuration,
                                                   completionHandler: { (error) in
          print(error ?? "")
        })
      } else {
        print("How did you ended here ?")
      }
    }))
    #endif

    // The project
    self.settings.append([
      Setting(Text.giveFeedback, icon: #imageLiteral(resourceName: "megaphone"), action: { ( _ ) in
        App.log("Settings: Give feedback")
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["helloworld@asmartcode.com"])
        mailComposerVC.setSubject(Text.tpgoffline)
        mailComposerVC.setMessageBody("", isHTML: false)

        if MFMailComposeViewController.canSendMail() {
          self.present(mailComposerVC, animated: true, completion: nil)
        }
      }),
      Setting(Text.lastFeatures, icon: #imageLiteral(resourceName: "flag"), action: { (_) in
        self.performSegue(withIdentifier: "showNewFeatures", sender: self)
      }),
      Setting(Text.credits, icon: #imageLiteral(resourceName: "crows"), action: { (_) in
        self.performSegue(withIdentifier: "showCredits", sender: self)
      }),
      Setting(Text.githubWebpage, icon: #imageLiteral(resourceName: "github"), action: { (_) in
        let vc = SFSafariViewController(url: URL(string: URL.github)!,
                                        entersReaderIfAvailable: false)
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

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return self.settings[section].count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
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

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    self.tableView.deselectRow(at: indexPath, animated: true)
    let setting = self.settings[indexPath.section][indexPath.row]
    setting.action(setting)
  }

  override func tableView(_ tableView: UITableView,
                          titleForHeaderInSection section: Int) -> String? {
    return titles[section]
  }

  override func tableView(_ tableView: UITableView,
                          titleForFooterInSection section: Int) -> String? {
    return (section + 1) == tableView.numberOfSections ? Text.tpgofflineVersion : nil
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
    // swiftlint:disable:previous line_length
    controller.dismiss(animated: true, completion: nil)
  }
}

extension SettingsTableViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true)
  }
}
