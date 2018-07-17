//
//  PrivacyTableViewController.swift
//  tpg offline
//
//  Created by レミー on 17/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import SafariServices

class PrivacyTableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Text.privacy
    
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
    return section == 0 ? 1 : 2
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "privacyCell",
                                             for: indexPath)
    
    if indexPath.section == 0 {
      cell.textLabel?.text = Text.appPermissions
      cell.detailTextLabel?.text = ""
      cell.accessoryType = .disclosureIndicator
    } else {
      if indexPath.row == 0 {
        cell.textLabel?.text = Text.privacyStatement
        cell.detailTextLabel?.text = ""
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.textLabel?.text = "Fabric"
        cell.detailTextLabel?.text = Text.fabricDescription
        let statusSwitch = UISwitch(frame: CGRect.zero) as UISwitch
        statusSwitch.isOn = App.fabric
        statusSwitch.addTarget(self, action: #selector(self.toogleFabric),
                               for: .valueChanged)
        cell.accessoryView = statusSwitch
      }
    }
    
    cell.backgroundColor = App.cellBackgroundColor
    cell.textLabel?.textColor = App.textColor
    cell.detailTextLabel?.textColor = App.textColor
    cell.detailTextLabel?.numberOfLines = 0
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
    if indexPath.section == 0 {
      UIApplication.shared
        .openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    } else {
      if indexPath.row == 0 {
        let vc = SFSafariViewController(url: URL(string: URL.privacyStatement)!,
                                        entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
          vc.preferredBarTintColor = .black
        }
        vc.delegate = self
        
        self.present(vc, animated: true)
      } else {
        toogleFabric()
      }
    }
  }
  
  @objc func toogleFabric() {
    App.fabric.toggle()
    self.tableView.reloadData()
  }
  
  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension PrivacyTableViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true)
  }
}
