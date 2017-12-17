//
//  AddMonitoringLinesTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

struct AddMonitoring {
    static var line: String = ""
    static var fromHour: String = ""
    static var fromDate: Date = Date()
    static var toHour: String = ""
    static var days: String = ""
}

class AddMonitoringLinesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add new".localized

        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return App.lines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath) as? LineTableViewControllerRow
            else { return UITableViewCell() }

        cell.line = App.lines[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AddMonitoring.line = App.lines[indexPath.row].line
    }

}
