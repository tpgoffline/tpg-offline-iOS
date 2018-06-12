//
//  DarkModeTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 11/06/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit

class DarkModeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Dark mode".localized
        
        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.separatorColor = App.separatorColor
        }
        
        ColorModeManager.shared.addColorModeDelegate(self)
    }
    
    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return App.automaticDarkMode ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "darkModeRow", for: indexPath)

        let statusSwitch = UISwitch(frame: CGRect.zero) as UISwitch
        cell.backgroundColor = App.cellBackgroundColor
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Automatic".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.text = "From Sunset to Sunrise".localized
            cell.detailTextLabel?.textColor = App.textColor
            statusSwitch.isOn = App.automaticDarkMode
            statusSwitch.addTarget(self, action: #selector(self.changeAutomatic), for: .valueChanged)
        } else {
            cell.textLabel?.text = "Manual".localized
            cell.textLabel?.textColor = App.textColor
            cell.detailTextLabel?.text = ""
            statusSwitch.isOn = App.darkMode
            statusSwitch.addTarget(self, action: #selector(self.changeManual), for: .valueChanged)
        }
        
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
    
    @objc func changeAutomatic() {
        App.automaticDarkMode = !App.automaticDarkMode
        if App.automaticDarkMode && App.sunriseSunsetManager?.isDaytime ?? false && App.darkMode == true {
            App.darkMode = false
        } else if App.automaticDarkMode && App.sunriseSunsetManager?.isNighttime ?? false && App.darkMode == false {
            App.darkMode = true
        }
        self.tableView.reloadData()
    }
    
    @objc func changeManual() {
        App.darkMode = !App.darkMode
        if App.darkMode {
            App.automaticDarkMode = false
        }
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            changeAutomatic()
        } else {
            changeManual()
        }
    }
}
