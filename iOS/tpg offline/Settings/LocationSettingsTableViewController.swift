//
//  LocationSettingsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class LocationSettingsTableViewController: UITableViewController {

    let defaults = UserDefaults.standard
    let headers = ["Précision".localized, "Distance de proximité des arrêts".localized]
    let choices = [["Normale".localized, "Précise".localized, "Très précise".localized], ["100m".localized, "200m".localized, "500m".localized, "750m".localized, "1km".localized]]
    let values = [[0, 1, 2], [100, 200, 500, 750, 1000]]
    var rowSelected = [0, 0]

    override func viewDidLoad() {
        super.viewDidLoad()
        rowSelected[0] = values[0].index(of: defaults.integer(forKey: "locationAccurency"))!
        if defaults.integer(forKey: "proximityDistance") == 0 {
            defaults.set(500, forKey: "proximityDistance")
        }
        rowSelected[1] = values[1].index(of: defaults.integer(forKey: "proximityDistance"))!
        tableView.backgroundColor = AppValues.primaryColor

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices[section].count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choixTabDefaultCell", for: indexPath)

        cell.textLabel?.text = choices[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        if indexPath.row == rowSelected[indexPath.section] {
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "tick").maskWithColor(color: AppValues.textColor))
        } else {
            cell.accessoryView = nil
        }
        cell.textLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            defaults.set(values[0][indexPath.row], forKey: UserDefaultsKeys.locationAccurency.rawValue)
        } else {
            defaults.set(values[1][indexPath.row], forKey: UserDefaultsKeys.proximityDistance.rawValue)
        }
        rowSelected[indexPath.section] = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView()
        returnedView.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)

        let label = UILabel(frame: CGRect(x: 20, y: 5, width: 500, height: 30))
        label.text = headers[section]
        label.textColor = AppValues.textColor
        returnedView.addSubview(label)

        return returnedView
    }
}
