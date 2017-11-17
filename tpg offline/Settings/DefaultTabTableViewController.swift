//
//  DefaultTabTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class DefaultTabTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Default tab"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tabBarController?.tabBar.items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultTabCell", for: indexPath)

        guard let tab = (self.tabBarController?.tabBar.items ?? [])[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.imageView?.image = tab.image?.maskWith(color: App.textColor)
        cell.textLabel?.text = tab.title
        cell.textLabel?.textColor = App.textColor
        cell.accessoryType = App.defaultTab == indexPath.row ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        App.defaultTab = indexPath.row
        self.tableView.reloadData()
    }
}
