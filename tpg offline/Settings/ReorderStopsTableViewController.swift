//
//  ReorderStopsTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 23/01/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import Crashlytics

class ReorderStopsTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    App.log("Show reorder stops view")
    App.logEvent("Show reorder stops view")

    self.tableView.allowsSelection = false
    self.tableView.setEditing(true, animated: false)

    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(barButtonSystemItem: .refresh,
                      target: self,
                      action: #selector(reinitOrder))

    ColorModeManager.shared.addColorModeDelegate(self)

    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }

    title = "Reorder stops view".localized
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return App.stopsKeys.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "stopHeaderRow",
                                             for: indexPath)

    let key = App.stopsKeys[indexPath.row]
    if key == "location" {
      cell.textLabel?.text = "Nearest stops".localized
      cell.imageView?.image = #imageLiteral(resourceName: "location").maskWith(color: App.textColor)
    } else if key == "favorites" {
      cell.textLabel?.text = "Favorites".localized
      cell.imageView?.image = #imageLiteral(resourceName: "star").maskWith(color: App.textColor)
    } else {
      cell.textLabel?.text = key
      cell.imageView?.image = nil
    }

    cell.backgroundColor = App.cellBackgroundColor
    cell.textLabel?.textColor = App.textColor
    return cell
  }

  override func tableView(_ tableView: UITableView,
                          moveRowAt fromIndexPath: IndexPath,
                          to: IndexPath) {
    App.stopsKeys.rearrange(from: fromIndexPath.row, to: to.row)
    ColorModeManager.shared.updateColorMode()
  }

  override func tableView(_ tableView: UITableView,
                          editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    // swiftlint:disable:previous line_length
    return .none
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  @objc func reinitOrder() {
    let alertController = UIAlertController(title: Text.warning,
                                            message: Text.reinitAlphabeticalOrder,
                                            preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: Text.no,
                                            style: .cancel,
                                            handler: nil))
    alertController.addAction(UIAlertAction(title: Text.yes,
                                            style: .default,
                                            handler: { (_) in
      App.stopsKeys = ["location", "favorites"] + App.sortedStops.keys.sorted()
      self.tableView.reloadData()
    }))
    self.present(alertController, animated: true, completion: nil)
  }
}
