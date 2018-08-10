//
//  DefaultTabTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Crashlytics

class DefaultTabTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = Text.defaultTab

    App.log("Show default tab")
    App.logEvent("Show default tab")

    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }
    ColorModeManager.shared.addColorModeDelegate(self)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return self.tabBarController?.tabBar.items?.count ?? 0
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultTabCell",
                                             for: indexPath)

    guard let tab = (self.tabBarController?.tabBar.items ?? [])[safe: indexPath.row]
      else {
      return UITableViewCell()
    }

    cell.backgroundColor = App.cellBackgroundColor
    cell.imageView?.image = tab.image?.maskWith(color: App.textColor)
    cell.textLabel?.text = tab.title
    cell.textLabel?.textColor = App.textColor
    cell.accessoryType = App.defaultTab == indexPath.row ? .checkmark : .none

    return cell
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    App.defaultTab = indexPath.row
    self.tableView.reloadData()
  }
}
