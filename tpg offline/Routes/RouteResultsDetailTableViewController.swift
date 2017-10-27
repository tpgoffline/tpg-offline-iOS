//
//  RouteResultsDetailTableViewController.swift
//  tpg offline
//
//  Created by Remy on 10/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class RouteResultsDetailTableViewController: UITableViewController {

    var connection: RouteConnection?
    var zones: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Result"

        var stopsId = connection!.sections!.map({ $0.departure.station.id })
        stopsId += connection!.sections!.map({ $0.arrival.station.id })
        var stops: [Stop] = []
        for e in stopsId {
            if let stop = App.stops.filter({ $0.sbbId == e })[safe: 0] {
                stops.append(stop)
            }
        }
        for zone in stops.map({$0.pricingZone}) {
            zones += zone
        }
        zones = zones.uniqueElements

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStep" {
            guard let destinationViewController = segue.destination as? RouteStepViewController else {
                return
            }
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
                return
            }
            guard let row = tableView.cellForRow(at: selectedIndexPath) as? RouteResultDetailTableViewCell else {
                return
            }
            destinationViewController.section = row.section
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return zones.count > 1 ? 1 : 0
        default:
            return connection?.sections?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "warningCell", for: indexPath)

            let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                   NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = NSAttributedString(string: "Regional route".localized, attributes: titleAttributes)
            var zonesText = ""
            zones.forEach({ zonesText.append("\($0) / ")})
            zonesText.removeLast()
            zonesText.removeLast()
            let text = NSMutableAttributedString()
            text.normal("This route crosses several areas. Therefore, you must have a regional ticket/pass corresponding to these zones:\n".localized)
            text.bold(zonesText)
            cell.detailTextLabel?.attributedText = text
            cell.detailTextLabel?.numberOfLines = 0

            cell.backgroundColor = #colorLiteral(red: 1, green: 0.9215686275, blue: 0.231372549, alpha: 1)
            return cell
        } else {
            if connection?.sections?[safe: indexPath.row]?.walk != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "walkConnectionCell", for: indexPath)
                if let duration = connection?.sections?[safe: indexPath.row]?.walk?.duration,
                    duration != 0 {
                    cell.textLabel?.text = String(format: "Walk %@m".localized, "\(duration)")
                } else {
                    cell.textLabel?.text = "Walk".localized
                }
                cell.imageView?.image = #imageLiteral(resourceName: "transfer").maskWith(color: App.textColor)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultDetailCell", for: indexPath)
                    as? RouteResultDetailTableViewCell, let section = connection?.sections?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
                cell.section = section
                return cell
            }
        }

    }
}

extension RouteResultsDetailTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? RouteResultDetailTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "routeStepViewController") as?
            RouteStepViewController
            else { return nil }

        detailVC.section = row.section
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
