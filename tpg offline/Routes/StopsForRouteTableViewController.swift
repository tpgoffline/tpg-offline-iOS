//
//  StopsForRouteTableViewController.swift
//  tpg offline
//
//  Created by Remy on 10/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class StopsForRouteTableViewController: StopsTableViewController {

    var isFrom = true

    override func viewDidLoad() {
        self.askForRating = false
        super.viewDidLoad()
        title = isFrom ? "From...".localized : "To...".localized
        self.searchController.searchBar.placeholder = "Are you looking for a stop ?".localized
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = self.navigationController?.viewControllers[0] as? RoutesTableViewController else {
            return
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.searchController.searchBar.resignFirstResponder()
        let stop = (tableView.cellForRow(at: indexPath) as? StopsTableViewCell)?.stop
        App.log(string: "Selected \(stop?.code ?? "#!?") stop")
        if isFrom {
            viewController.route.from = stop
        } else {
            viewController.route.to = stop
        }
        self.navigationController?.popViewController(animated: true)
    }

    override func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                                    viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
