//
//  UpdateDeparturesTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/06/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class UpdateDeparturesTableViewController: UITableViewController,
DownloadOfflineDeparturesDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    title = Text.offlineDepartures
    OfflineDeparturesManager.shared.addDownloadOfflineDeparturesDelegate(self)
    ColorModeManager.shared.addColorModeDelegate(self)

    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.separatorColor = App.separatorColor
    }
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return section == 2 ? 2 : 1
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell =
        tableView.dequeueReusableCell(withIdentifier: "updateDeparturesCell",
                                      for: indexPath)
      let statusSwitch = UISwitch(frame: CGRect.zero) as UISwitch
      cell.backgroundColor = App.cellBackgroundColor
      cell.textLabel?.text = Text.automatic
      cell.textLabel?.textColor = App.textColor
      cell.detailTextLabel?.text = Text.offlineDeparturesOnWifi
      cell.detailTextLabel?.textColor = App.textColor
      cell.detailTextLabel?.numberOfLines = 0
      statusSwitch.isOn = App.automaticDeparturesDownload
      statusSwitch.addTarget(self,
                             action: #selector(self.changeAutomatic),
                             for: .valueChanged)
      cell.accessoryView = statusSwitch
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
    } else if indexPath.section == 1 {
      guard let cell =
        tableView.dequeueReusableCell(withIdentifier: "updateDeparturesButtonCell",
                                      for: indexPath)
          as? UpdateDeparturesButton else {
            return UITableViewCell()
      }
      if App.darkMode {
        let selectedView = UIView()
        selectedView.backgroundColor = .black
        cell.selectedBackgroundView = selectedView
      } else {
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white.darken(by: 0.1)
        cell.selectedBackgroundView = selectedView
      }
      cell.accessoryView = nil
      cell.textLabel?.text = ""
      cell.detailTextLabel?.text = ""
      cell.backgroundColor = App.cellBackgroundColor
      return cell
    } else {
      if indexPath.row == 0 {
        let cell =
          tableView.dequeueReusableCell(withIdentifier: "updateDeparturesCell",
                                        for: indexPath)
        let statusSwitch = UISwitch(frame: CGRect.zero) as UISwitch
        cell.backgroundColor = App.cellBackgroundColor
        cell.textLabel?.text = Text.downloadMaps
        cell.textLabel?.textColor = App.textColor
        cell.detailTextLabel?.text = ""

        statusSwitch.isOn = App.downloadMaps
        statusSwitch.addTarget(self,
                               action: #selector(self.changeDownloadMaps),
                               for: .valueChanged)
        cell.accessoryView = statusSwitch
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
      } else {
        let cell =
          tableView.dequeueReusableCell(withIdentifier: "updateDeparturesCell",
                                        for: indexPath)
        let statusSwitch = UISwitch(frame: CGRect.zero) as UISwitch
        cell.backgroundColor = App.cellBackgroundColor
        cell.textLabel?.text = Text.allowWithMobileData
        cell.textLabel?.textColor = App.textColor
        cell.detailTextLabel?.text = ""

        statusSwitch.isOn = App.allowDownloadWithMobileData
        statusSwitch.addTarget(self,
                               action: #selector(self.changeAllowDownloadWithMobileData),
                               for: .valueChanged)
        cell.accessoryView = statusSwitch
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
    }
  }

  override func tableView(_ tableView: UITableView,
                          titleForFooterInSection section: Int) -> String? {
    if section == 1 {
      if OfflineDeparturesManager.shared.status == .error {
        return "An error occurred".localized
      } else {
        if UserDefaults.standard.bool(forKey: "offlineDeparturesUpdateAvailable") {
          return Text.updateAvailable
        } else if UserDefaults.standard.string(forKey: "departures.json.md5") == "" {
          return Text.noDeparturesInstalled
        } else {
          return Text.offlineDeparturesVersion
        }
      }
    } else {
      return ""
    }
  }

  @objc func changeAutomatic() {
    App.automaticDeparturesDownload = !App.automaticDeparturesDownload
    self.tableView.reloadData()
  }

  @objc func changeDownloadMaps() {
    App.downloadMaps = !App.downloadMaps
    self.tableView.reloadData()
  }

  @objc func changeAllowDownloadWithMobileData() {
    App.allowDownloadWithMobileData = !App.allowDownloadWithMobileData
    self.tableView.reloadData()
  }

  func updateDownloadStatus() {
    if OfflineDeparturesManager.shared.status == .notDownloading {
      self.tableView.reloadData()
    }
  }

  deinit {
    OfflineDeparturesManager.shared.removeDownloadOfflineDeparturesDelegate(self)
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

class UpdateDeparturesButton: UITableViewCell, DownloadOfflineDeparturesDelegate {
  func updateDownloadStatus() {
    self.state = OfflineDeparturesManager.shared.status
  }

  @IBOutlet weak var button: UIButton!

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    OfflineDeparturesManager.shared.addDownloadOfflineDeparturesDelegate(self)
    self.state = OfflineDeparturesManager.shared.status
  }

  deinit {
    OfflineDeparturesManager.shared.removeDownloadOfflineDeparturesDelegate(self)
  }

  var state: OfflineDeparturesManager.OfflineDeparturesStatus = .notDownloading {
    didSet {
      switch state {
      case .downloading:
        self.button.setTitle("Downloading...".localized, for: .disabled)
        self.button.isEnabled = false
      case .processing:
        self.button.setTitle("Saving...".localized, for: .disabled)
        self.button.isEnabled = false
      default:
        self.button.setTitle("Download now".localized, for: .normal)
        self.button.isEnabled = true
      }
    }
  }

  @IBAction func downloadButtonPushed() {
    if OfflineDeparturesManager.shared.status == any(of: .notDownloading, .error) {
      OfflineDeparturesManager.shared.download()
    }
  }
}
