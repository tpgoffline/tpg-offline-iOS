//
//  UpdateDeparturesTableViewController.swift
//  tpg offline
//
//  Created by Rémy on 11/06/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit

class UpdateDeparturesTableViewController: UITableViewController, DownloadOfflineDeparturesDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Offline departures".localized
        DownloadOfflineDeparturesManager.shared.addDownloadOfflineDeparturesDelegate(self)
        ColorModeManager.shared.addColorModeDelegate(self)
        
        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.separatorColor = App.separatorColor
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "updateDeparturesCell", for: indexPath)
            let statusSwitch = UISwitch(frame: CGRect.zero) as UISwitch
            cell.backgroundColor = App.cellBackgroundColor
            cell.textLabel?.text = "Automatic".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.text = "Offline departures will be downloaded with a Wi-Fi connection".localized
            cell.detailTextLabel?.textColor = App.textColor
            cell.detailTextLabel?.numberOfLines = 0
            statusSwitch.isOn = App.automaticDeparturesDownload
            statusSwitch.addTarget(self, action: #selector(self.changeAutomatic), for: .valueChanged)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "updateDeparturesButtonCell", for: indexPath) as? UpdateDeparturesButton else {
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
        }        
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            if DownloadOfflineDeparturesManager.shared.status == .error {
                return "An error occurred".localized
            } else {
                return UserDefaults.standard.bool(forKey: "offlineDeparturesUpdateAvailable") ? "An update is available".localized :
                    (UserDefaults.standard.string(forKey: "departures.json.md5") == "" ? "No offline departures installed".localized : String(format: "Offline departures version: %@".localized, UserDefaults.standard.string(forKey: "departures.json.md5")!))
            }
        } else {
            return ""
        }
    }
    
    @objc func changeAutomatic() {
        App.automaticDeparturesDownload = !App.automaticDeparturesDownload
        self.tableView.reloadData()
    }
    
    func updateDownloadStatus() {
        if DownloadOfflineDeparturesManager.shared.status == .notDownloading {
            self.tableView.reloadData()
        }
    }
    
    deinit {
        DownloadOfflineDeparturesManager.shared.removeDownloadOfflineDeparturesDelegate(self)
        ColorModeManager.shared.removeColorModeDelegate(self)
    }
}

class UpdateDeparturesButton: UITableViewCell, DownloadOfflineDeparturesDelegate {
    func updateDownloadStatus() {
        self.state = DownloadOfflineDeparturesManager.shared.status
    }
    
    @IBOutlet weak var button: UIButton!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        DownloadOfflineDeparturesManager.shared.addDownloadOfflineDeparturesDelegate(self)
        self.state = DownloadOfflineDeparturesManager.shared.status
    }
    
    deinit {
        DownloadOfflineDeparturesManager.shared.removeDownloadOfflineDeparturesDelegate(self)
    }
    
    var state: DownloadOfflineDeparturesManager.OfflineDeparturesStatus = .notDownloading {
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
        DownloadOfflineDeparturesManager.shared.download()
    }
}
