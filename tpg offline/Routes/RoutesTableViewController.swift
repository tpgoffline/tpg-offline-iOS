//
//  RoutesTableViewController.swift
//  tpg offline
//
//  Created by Remy on 09/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import Crashlytics

protocol RouteSelectionDelegate: class {
  func routeSelected(_ newRoute: Route)
}

class RoutesTableViewController: UITableViewController {

  public var route = Route() {
    didSet {
      self.tableView.reloadData()
    }
  }

  weak var delegate: RouteSelectionDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.splitViewController?.delegate = self
    self.splitViewController?.preferredDisplayMode = .allVisible

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 44

    navigationItem.rightBarButtonItems = [
      self.editButtonItem,
      UIBarButtonItem(image: #imageLiteral(resourceName: "reverse"),
                      style: .plain,
                      target: self,
                      action: #selector(self.reverseStops))
    ]

    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
      navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedStringKey.foregroundColor: App.textColor]
    }

    navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: App.textColor]

    if App.darkMode {
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }

    ColorModeManager.shared.addColorModeDelegate(self)

    guard let rightNavController = self.splitViewController?.viewControllers.last
      as? UINavigationController,
      let detailViewController = rightNavController.topViewController
        as? RouteResultsTableViewController else { return }
    self.delegate = detailViewController
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.tableView.reloadData()
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

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section == 1 {
      return App.favoritesRoutes.count
    }
    return 5 + ((self.route.via?.count ?? 0) >= 5 ? 4 : (self.route.via?.count ?? 0))
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      if indexPath.row == 4 + (self.route.via?.count ?? 0) -
        ((self.route.via?.count ?? 0) >= 5 ? 1 : 0) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routesCell",
                                                 for: indexPath)
        cell.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        let titleAttributes =
          [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white
        cell.imageView?.image = #imageLiteral(resourceName: "magnify").maskWith(color: App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white)
        cell.textLabel?.attributedText =
          NSAttributedString(string: Text.search,
                             attributes: titleAttributes)
        cell.detailTextLabel?.text = ""
        cell.accessoryType = .disclosureIndicator

        let selectedView = UIView()
        selectedView.backgroundColor = cell.backgroundColor?.darken(by: 0.1)
        cell.selectedBackgroundView = selectedView

        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routesCell",
                                                 for: indexPath)
        let titleAttributes =
          [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        let subtitleAttributes =
          [NSAttributedStringKey.font:
            UIFont.preferredFont(forTextStyle: .subheadline)]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = App.textColor
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.textColor = App.textColor
        cell.backgroundColor = App.cellBackgroundColor
        cell.accessoryType = .disclosureIndicator

        if App.darkMode {
          let selectedView = UIView()
          selectedView.backgroundColor = .black
          cell.selectedBackgroundView = selectedView
        } else {
          let selectedView = UIView()
          selectedView.backgroundColor = UIColor.white.darken(by: 0.1)
          cell.selectedBackgroundView = selectedView
        }

        switch indexPath.row {
        case 0:
          cell.imageView?.image = #imageLiteral(resourceName: "firstStep@20").maskWith(color: App.textColor)
          cell.textLabel?.attributedText =
            NSAttributedString(string: Text.from, attributes: titleAttributes)
          cell.detailTextLabel?.attributedText =
            NSAttributedString(string: self.route.from?.name ?? "",
                               attributes: subtitleAttributes)
        case 2 + (self.route.via?.count ?? 0) -
          ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
          cell.imageView?.image = #imageLiteral(resourceName: "endStep@20").maskWith(color: App.textColor)
          cell.textLabel?.attributedText =
            NSAttributedString(string: Text.to,
                               attributes: titleAttributes)
          cell.detailTextLabel?.attributedText =
            NSAttributedString(string: self.route.to?.name ?? "",
                               attributes: subtitleAttributes)
        case 3 + (self.route.via?.count ?? 0) -
          ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
          cell.imageView?.image = #imageLiteral(resourceName: "clock").maskWith(color: App.textColor)
          cell.textLabel?.attributedText =
            NSAttributedString(string: self.route.arrivalTime ?
              Text.arrivalAt : Text.departureAt,
                               attributes: titleAttributes)
          let dateFormatter = DateFormatter()
          dateFormatter.dateStyle = Calendar.current.isDateInToday(self.route.date) ?
            .none : .short
          dateFormatter.timeStyle = .short
          cell.detailTextLabel?.attributedText =
            NSAttributedString(string: dateFormatter.string(from: self.route.date),
                               attributes: subtitleAttributes)
        default:
          cell.imageView?.image = #imageLiteral(resourceName: "middleStep@20").maskWith(color: App.textColor)
          let viaNumber = indexPath.row - 1
          if (self.route.via?.count ?? 0) == 0 {
            cell.textLabel?.attributedText =
              NSAttributedString(string: Text.via,
                                 attributes: titleAttributes)
          } else {
            cell.textLabel?.attributedText =
              NSAttributedString(string: Text.via(number: viaNumber),
                                 attributes: titleAttributes)
          }

          if let stop = self.route.via?[safe: viaNumber] {
            cell.detailTextLabel?.attributedText =
              NSAttributedString(string: stop.name, attributes: subtitleAttributes)
          } else {
            cell.detailTextLabel?.attributedText =
              NSAttributedString(string: Text.optional,
                                 attributes: subtitleAttributes)
            cell.detailTextLabel?.textColor = App.textColor.lighten()
          }
        }
        return cell
      }
    } else {
      self.tableView.deselectRow(at: indexPath, animated: true)
      guard let cell =
        tableView.dequeueReusableCell(withIdentifier: "favoriteRouteCell",
                                      for: indexPath) as? FavoriteRouteTableViewCell
        else { return UITableViewCell() }
      cell.route = App.favoritesRoutes[indexPath.row]
      if indexPath.row % 2 == 0 {
        cell.backgroundColor = App.cellBackgroundColor
      } else {
        cell.backgroundColor = App.cellBackgroundColor.darken(by: 0.025)
      }
      return cell
    }
  }

  @objc func search() {
    if route.to == nil, let stop = route.via?.last {
      route.to = stop
      route.via?.removeLast()
    }
    if route.validRoute == .valid {
      self.delegate?.routeSelected(self.route)
      if let detailViewController = delegate as? RouteResultsTableViewController,
        let detailNavigationController = detailViewController.navigationController {
        splitViewController?.showDetailViewController(detailNavigationController,
                                                      sender: nil)
        detailNavigationController.popToRootViewController(animated: false)
      }
    } else {
      let message: String
      switch route.validRoute {
      case .departureAndArrivalMissing:
        message = Text.departureAndArrivalMissing
      case .departureMissing:
        message = Text.departureMissing
      case .arrivalMissing:
        message = Text.arrivalMissing
      case .sameDepartureAndArrival:
        message = Text.sameDepartureAndArrival
      default:
        message = Text.missingErrorMessage
      }
      let alertView = UIAlertController(title: Text.invalidRoute,
                                        message: message,
                                        preferredStyle: .alert)
      alertView.addAction(UIAlertAction(title: Text.ok,
                                        style: .default,
                                        handler: nil))
      self.present(alertView, animated: true, completion: nil)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showStopsForRoute" {
      guard let indexPath = sender as? IndexPath else { return }
      guard let destinationViewController = segue.destination as?
        StopsForRouteTableViewController else {
        return
      }
      switch indexPath.row {
      case 0:
        destinationViewController.fromToVia = .from
      case 2 + (self.route.via?.count ?? 0) -
        ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
        destinationViewController.fromToVia = .to
      default:
        destinationViewController.fromToVia = .via(indexPath.row - 1)
      }
    }
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 {
      self.route = App.favoritesRoutes[indexPath.row]
      self.route.date = Date()
      self.route.arrivalTime = false
      search()
      return
    }
    switch indexPath.row {
    case 0:
      App.log("Selected from stop select")
      performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
    case 2 + (self.route.via?.count ?? 0) -
      ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
      App.log("Selected to stop select")
      performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
    case 3 + (self.route.via?.count ?? 0) -
      ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
      App.log("Selected date select")
      DatePickerDialog(showCancelButton: false)
        .show("Select date".localized,
              doneButtonTitle: "OK".localized,
              cancelButtonTitle: "Cancel".localized,
              nowButtonTitle: "Now".localized,
              defaultDate: self.route.date,
              minimumDate: nil,
              maximumDate: nil,
              datePickerMode: .dateAndTime,
              arrivalTime: self.route.arrivalTime) { arrivalTime, date in
                if let date = date {
                  self.route.date = date
                  self.route.arrivalTime = arrivalTime
                  print(arrivalTime)
                }
      }
    case 4 + (self.route.via?.count ?? 0) -
      ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
      search()
    default:
      App.log("Selected to stop select")
      performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView,
                          canEditRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == 1 {
      return true
    } else {
      switch indexPath.row {
      case 0:
        return false
      case 2 + (self.route.via?.count ?? 0) -
        ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
        return false
      case 3 + (self.route.via?.count ?? 0) -
        ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
        return !self.tableView.isEditing
      case 4 + (self.route.via?.count ?? 0) -
        ((self.route.via?.count ?? 0) >= 5 ? 1 : 0):
        return false
      case 1 + (self.route.via?.count ?? 0):
        return false
      default:
        return self.route.via?.count != 0
      }
    }
  }

  override func tableView(_ tableView: UITableView,
                          editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    // swiftlint:disable:previous line_length
    if indexPath.section == 0,
      indexPath.row == 3 + (self.route.via?.count ?? 0) -
        ((self.route.via?.count ?? 0) >= 5 ? 1 : 0) {
      let setToNowAction = UITableViewRowAction(style: .normal,
                                                title: Text.now) { (_, _) in
        self.route.date = Date()
      }
      if App.darkMode {
        setToNowAction.backgroundColor = .black
      } else {
        setToNowAction.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
      }
      return [setToNowAction]
    } else if indexPath.section == 1 {
      let reverseAction = UITableViewRowAction(style: .normal,
                                               title: Text.reversed) { (_, _) in
        self.route = App.favoritesRoutes[indexPath.row]
        let from = self.route.from
        let to = self.route.to
        self.route.from = to
        self.route.to = from
        self.route.date = Date()
        self.search()
      }
      if App.darkMode {
        reverseAction.backgroundColor = .black
      } else {
        reverseAction.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1)
      }
      return [reverseAction, UITableViewRowAction(style: .destructive,
                                                  title: Text.delete,
                                                  handler: { (_, indexPath) in
        App.favoritesRoutes.remove(at: indexPath.row)
        self.tableView.reloadData()
      })]
    } else {
      return [UITableViewRowAction(style: .destructive,
                                   title: Text.delete,
                                   handler: { (_, indexPath) in
        self.route.via?.remove(at: indexPath.row - 1)
        self.tableView.reloadData()
      })]
    }
  }

  override func tableView(_ tableView: UITableView,
                          moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    App.favoritesRoutes.rearrange(from: fromIndexPath.row, to: to.row)
  }

  override func tableView(_ tableView: UITableView,
                          canMoveRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == 1
  }
}

extension RoutesTableViewController: UISplitViewControllerDelegate {
  func splitViewController(_ splitViewController: UISplitViewController,
                           collapseSecondary secondaryViewController: UIViewController, // swiftlint:disable:this line_length
                           onto primaryViewController: UIViewController) -> Bool {
    return true
  }
}
