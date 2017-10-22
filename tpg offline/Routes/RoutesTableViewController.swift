//
//  RoutesTableViewController.swift
//  tpg offline
//
//  Created by Remy on 09/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {

    public var route = Route() {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "reverse"), style: .plain, target: self, action: #selector(self.reverseStops))
        ]

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
    }

    @objc func reverseStops() {
        let from = self.route.from
        let to = self.route.to
        self.route.from = to
        self.route.to = from
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return App.favoritesRoutes.count
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "routesButtonCell", for: indexPath) as? SearchButtonTableViewCell
                    else { return UITableViewCell() }
                cell.button.addTarget(self, action: #selector(self.search), for: .touchUpInside)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "routesCell", for: indexPath)
                let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
                let subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textColor = App.textColor
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.textColor = App.textColor

                switch indexPath.row {
                case 0:
                    cell.imageView?.image = #imageLiteral(resourceName: "from").maskWith(color: App.textColor)
                    cell.textLabel?.attributedText = NSAttributedString(string: "From".localized, attributes: titleAttributes)
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: self.route.from?.name ?? "", attributes: subtitleAttributes)
                case 1:
                    cell.imageView?.image = #imageLiteral(resourceName: "to").maskWith(color: App.textColor)
                    cell.textLabel?.attributedText = NSAttributedString(string: "To".localized, attributes: titleAttributes)
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: self.route.to?.name ?? "", attributes: subtitleAttributes)
                case 2:
                    cell.imageView?.image = #imageLiteral(resourceName: "clock").maskWith(color: App.textColor)
                    cell.textLabel?.attributedText = NSAttributedString(string: self.route.arrivalTime ?
                        "Arrival at".localized : "Departure at".localized, attributes: titleAttributes)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = Calendar.current.isDateInToday(self.route.date) ? .none : .short
                    dateFormatter.timeStyle = .short
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: dateFormatter.string(from: self.route.date),
                                                                              attributes: subtitleAttributes)
                default:
                    print("WTF ?!")
                }
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteRouteCell", for: indexPath) as? FavoriteRouteTableViewCell
                else { return UITableViewCell() }
            cell.route = App.favoritesRoutes[indexPath.row]
            return cell
        }
    }

    @objc func search() {
        if route.validRoute {
            performSegue(withIdentifier: "showResults", sender: self)
        }
    }

    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 3 && indexPath.section == 0 ? 60 : 44
    }*/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStopsForRoute" {
            guard let indexPath = sender as? IndexPath else { return }
            guard let destinationViewController = segue.destination as? StopsForRouteTableViewController else {
                return
            }
            destinationViewController.isFrom = indexPath.row == 0
        } else if segue.identifier == "showResults" {
            guard let destinationViewController = segue.destination as? RouteResultsTableViewController else {
                return
            }
            destinationViewController.route = self.route
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.route = App.favoritesRoutes[indexPath.row]
            self.route.date = Date()
            search()
            return
        }
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
        case 1:
            performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
        case 2:
            DatePickerDialog(showCancelButton: false).show("Select date".localized,
                                                           doneButtonTitle: "OK".localized,
                                                           cancelButtonTitle: "Cancel".localized,
                                                           defaultDate: self.route.date,
                                                           minimumDate: Date(),
                                                           maximumDate: nil,
                                                           datePickerMode: .dateAndTime,
                                                           arrivalTime: self.route.arrivalTime) { arrivalTime, date in
                                                            if let date = date {
                                                                self.route.date = date
                                                                self.route.arrivalTime = arrivalTime
                                                                print(arrivalTime)
                                                            }
            }
        case 3:
            tableView.deselectRow(at: indexPath, animated: false)
        default:
            break
        }
    }
}
