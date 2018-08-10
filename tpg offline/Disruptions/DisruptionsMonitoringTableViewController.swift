//
//  DisruptionsMonitoringTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

class DisruptionsMonitoringTableViewController: UITableViewController {

  var disruptionMonitoringList: [DisruptionMonitoring] = []

  var requestStatus: RequestStatus = .loading {
    didSet {
      self.tableView.allowsSelection = requestStatus == .ok
      self.tableView.reloadData()
    }
  }

  var lines: [String] {
    return disruptionMonitoringList.map({ $0.line }).uniqueElements.sorted(by: {
      if let a = Int($0), let b = Int($1) {
        return a < b
      } else { return $0 < $1 }})
  }

  var firstOpeningOfDisruptionsMonitoring: Bool {
    get {
      return UserDefaults.standard.bool(forKey: #function)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    App.log("Show disruptions monitoring")
    App.logEvent("Show disruptions monitoring")

    self.navigationItem.rightBarButtonItems = [
      self.editButtonItem,
      UIBarButtonItem(barButtonSystemItem: .add,
                      target: self,
                      action: #selector(addLineMonitoring)),
      UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                      style: .plain,
                      target: self,
                      action: #selector(self.reload),
                      accessbilityLabel: Text.reload)
    ]

    if App.apnsToken == "" {
      let alertController = UIAlertController(title: Text.sorry,
                                              message: Text.apnsError,
                                              preferredStyle: .alert)
      let action = UIAlertAction(title: Text.ok, style: .default) { _ in
        self.navigationController?.popToRootViewController(animated: true)
      }
      alertController.addAction(action)
      present(alertController, animated: true, completion: nil)
    }

    if firstOpeningOfDisruptionsMonitoring == true, App.apnsToken != "" {
      firstOpeningOfDisruptionsMonitoring = false
      let alertController =
        UIAlertController(title: Text.disruptionsMonitoring,
                          message: Text.disruptionsMonitoringSubtitle,
                          preferredStyle: .alert)
      let action = UIAlertAction(title: Text.ok, style: .default) { _ in
        self.navigationController?.popToRootViewController(animated: true)
      }
      alertController.addAction(action)
      present(alertController, animated: true, completion: nil)
    }

    title = Text.monitoring

    if App.darkMode {
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }

    refreshControl = UIRefreshControl()

    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      self.tableView.addSubview(refreshControl!)
    }

    refreshControl?.addTarget(self,
                              action: #selector(self.reload),
                              for: .valueChanged)
    refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

    ColorModeManager.shared.addColorModeDelegate(self)

    reload()
  }

  @objc func reload() {
    Alamofire.request(URL.monitoring).responseData { (response) in
      if let data = response.data {
        let jsonDecoder = JSONDecoder()

        do {
          let json = try jsonDecoder.decode([DisruptionMonitoring].self, from: data)
          self.disruptionMonitoringList = json
          self.requestStatus = json.count == 0 ? .noResults : .ok
        } catch {
          self.requestStatus = .error
          return
        }
      } else {
        self.requestStatus = .error
      }
      self.refreshControl?.endRefreshing()
    }
  }

  @objc func addLineMonitoring() {
    performSegue(withIdentifier: "addLineMonitoring", sender: self)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.reload()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    if requestStatus == any(of: .loading, .error, .noResults) {
      return 1
    }
    return lines.count
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if requestStatus == any(of: .loading, .error, .noResults) {
      return 1
    }
    return disruptionMonitoringList.filter({ $0.line == lines[section] }).count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if requestStatus == any(of: .loading, .error, .noResults) {
      let cell = tableView.dequeueReusableCell(withIdentifier: "contextCell",
                                               for: indexPath)
      cell.textLabel?.numberOfLines = 0
      cell.detailTextLabel?.numberOfLines = 0
      let selectedView = UIView()
      cell.backgroundColor = App.cellBackgroundColor
      cell.textLabel?.textColor = App.textColor
      cell.detailTextLabel?.textColor = App.textColor
      selectedView.backgroundColor = App.darkMode ? .black : .white
      cell.selectedBackgroundView = selectedView
      switch requestStatus {
      case .loading:
        cell.textLabel?.text = Text.loading
        cell.detailTextLabel?.text = ""
      case .noResults:
        cell.textLabel?.text = Text.noLinesMonitored
        cell.detailTextLabel?.text = Text.noLinesMonitoredSubtitle
      case .error:
        cell.textLabel?.text = Text.noInternetMonitoredLines
        cell.detailTextLabel?.text = Text.noInternetMonitoredLinesSubtitle
      default:
        print("Seriously, how did you ended here?")
      }
      return cell
    } else {
      let cellId = "disruptionsMonitoringCell"
      guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                     for: indexPath)
        as? DisruptionsMonitoringTableViewCell else {
          return UITableViewCell()
      }

      cell.disruptionMonitoring = disruptionMonitoringList.filter({
        $0.line == lines[indexPath.section]
      })[indexPath.row]

      return cell
    }
  }

  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    if requestStatus == any(of: .loading, .error, .noResults) {
      return nil
    }
    let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
    let color = App.color(for: lines[section])
    headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : color
    headerCell?.textLabel?.text = String(format: "Line %@".localized, lines[section])
    headerCell?.textLabel?.textColor = App.darkMode ? color : color.contrast

    return headerCell
  }

  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    if requestStatus == any(of: .loading, .error, .noResults) {
      return CGFloat.leastNonzeroMagnitude
    }
    return 44
  }

  override func tableView(_ tableView: UITableView,
                          canEditRowAt indexPath: IndexPath) -> Bool {
    if requestStatus == any(of: .loading, .error, .noResults) {
      return false
    }
    return true
  }

  override func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let row = tableView.cellForRow(at: indexPath)
        as? DisruptionsMonitoringTableViewCell else { return }
      guard let disruptionMonitoring = row.disruptionMonitoring else { return }
      if let position =
        self.disruptionMonitoringList.index(of: disruptionMonitoring) {
        let parameters: Parameters = [
          "line": disruptionMonitoring.line,
          "fromHour": disruptionMonitoring.fromHour,
          "toHour": disruptionMonitoring.toHour,
          "days": disruptionMonitoring.days
        ]
        Alamofire
          .request(URL.monitoring,
                   method: .delete,
                   parameters: parameters)
          .responseString(completionHandler: { (response) in
          if let string = response.result.value, string == "1" {
            self.disruptionMonitoringList.remove(at: position)
            self.tableView.reloadData()
          }
        })
      }
    }
  }
}

class DisruptionsMonitoringTableViewCell: UITableViewCell {
  @IBOutlet weak var hoursLabel: UILabel!
  @IBOutlet weak var daysLabel: UILabel!

  var disruptionMonitoring: DisruptionMonitoring? {
    didSet {
      guard let disruptionMonitoring = self.disruptionMonitoring else { return }
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      var time = dateFormatter.date(from: disruptionMonitoring.fromHour)
      let fromHour = DateFormatter.localizedString(
        from: time ?? Date(),
        dateStyle: DateFormatter.Style.none,
        timeStyle: DateFormatter.Style.short)
      time = dateFormatter.date(from: disruptionMonitoring.toHour)
      let toHour = DateFormatter.localizedString(
        from: time ?? Date(),
        dateStyle: DateFormatter.Style.none,
        timeStyle: DateFormatter.Style.short)
      self.hoursLabel.text = "\(fromHour) - \(toHour)"

      let daysI = self.disruptionMonitoring?.days.split(separator: ":").map({
        Int($0) ?? -1
      }) ?? []
      var days: [String] = []
      for x in daysI {
        switch x {
        case 0:
          days.append("Monday".localized)
        case 1:
          days.append("Tuesday".localized)
        case 2:
          days.append("Wednesday".localized)
        case 3:
          days.append("Thursday".localized)
        case 4:
          days.append("Friday".localized)
        case 5:
          days.append("Saturday".localized)
        case 6:
          days.append("Sunday".localized)
        default:
          print("I don't know this day")
        }
      }
      self.daysLabel.text = days.joined(separator: " - ")
      let selectedView = UIView()
      selectedView.backgroundColor = .white

      self.backgroundColor = App.cellBackgroundColor
      self.hoursLabel.textColor = App.textColor
      self.daysLabel.textColor = App.textColor
      selectedView.backgroundColor = App.darkMode ? .black : .white
      self.selectedBackgroundView = selectedView
    }
  }
}
