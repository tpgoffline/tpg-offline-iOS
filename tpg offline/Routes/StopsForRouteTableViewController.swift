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
    case via(Int)
}

class StopsForRouteTableViewController: StopsTableViewController {

    var fromToVia: FromToVia = .from

    override func viewDidLoad() {
        self.askForRating = false
        super.viewDidLoad()
        switch fromToVia {
        case .from:
            title = "From...".localized
        case .to:
            title = "To...".localized
        case .via(_):
            title = "Via...".localized
        }
        self.searchController.searchBar.placeholder = "Are you looking for a stop ?".localized
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = self.navigationController?.viewControllers[0] as? RoutesTableViewController else {
            return
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.searchController.searchBar.resignFirstResponder()
        let stop = (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?.stop
        App.log("Selected \(stop?.code ?? "#!?") stop")
        switch fromToVia {
        case .from:
            title = "From...".localized
        case .to:
            title = "To...".localized
        case .via:
            title = "Via...".localized
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
        return nil
    }
}
