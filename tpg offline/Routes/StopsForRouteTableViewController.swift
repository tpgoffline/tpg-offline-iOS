//
//  StopsForRouteTableViewController.swift
//  tpg offline
//
//  Created by Remy on 10/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

enum FromToVia {
  case from
  case to
  case via(Int) // swiftlint:disable:this identifier_name
}

class StopsForRouteTableViewController: StopsTableViewController {

  var fromToVia: FromToVia = .from

  override func viewDidLoad() {
    self.askForRating = false
    super.viewDidLoad()
    switch fromToVia {
    case .from:
      title = Text.fromWithDots
    case .to:
      title = Text.toWithDots
    case .via:
      title = Text.viaWithDots
    }
    self.searchController.searchBar.placeholder = Text.lookingForAStop
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let viewController = self.navigationController?.viewControllers[0]
      as? RoutesTableViewController else { return }
    self.tableView.deselectRow(at: indexPath, animated: true)
    self.searchController.searchBar.resignFirstResponder()
    let stop = (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?.stop
    App.log("Selected \(stop?.code ?? "#!?") stop")
    switch fromToVia {
    case .from:
      title = Text.fromWithDots
    case .to:
      title = Text.toWithDots
    case .via:
      title = Text.viaWithDots
    }
    switch fromToVia {
    case .from:
      viewController.route.from = stop
    case .to:
      viewController.route.to = stop
    case .via(let index):
      guard let stop = stop else { return }
      if viewController.route.via == nil {
        viewController.route.via = [stop]
      } else if viewController.route.via![safe: index] != nil {
        viewController.route.via![index] = stop
      } else {
        viewController.route.via!.append(stop)
      }
    }
    self.navigationController?.popViewController(animated: true)
  }

  override func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                                  viewControllerForLocation location: CGPoint) -> UIViewController? {
    // swiftlint:disable:previous line_length
    return nil
  }
}
