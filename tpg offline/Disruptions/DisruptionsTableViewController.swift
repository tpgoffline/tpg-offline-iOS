//
//  DisruptionsTableViewController.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 18/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

class DisruptionsTableViewController: UITableViewController {

    var disruptions: DisruptionsGroup? {
        didSet {
            guard let disruptions = self.disruptions else { return }
            self.keys = disruptions.disruptions.keys.sorted(by: {
                if let a = Int($0), let b = Int($1) {
                    return a < b
                } else { return $0 < $1 }})
        }
    }

    var devDisruptions: [String: [DevDisruption]]?
    var requestStatus: RequestStatus  = .loading {
        didSet {
            if requestStatus == .error {
                let alertController = UIAlertController(title: "Error".localized,
                                                        message: "Sorry, there is an error. Are you sure your are connected to internet ?".localized,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    var keys: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        Answers.logCustomEvent(withName: "Show disruptions", customAttributes: [:])

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.allowsSelection = false

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]

        self.refreshDisruptions()

        refreshControl = UIRefreshControl()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl!)
        }

        refreshControl?.addTarget(self, action: #selector(refreshDisruptions), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "binoculars"),
                            style: .plain,
                            target: self,
                            action: #selector(self.pushDisruptionsMonitoring),
                            accessbilityLabel: "Disruptions monitoring".localized),
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.refreshDisruptions),
                            accessbilityLabel: "Reload departures".localized)
        ]
        if App.darkMode {
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }

        ColorModeManager.shared.addColorModeDelegate(self)
    }

    @objc func pushDisruptionsMonitoring() {
        performSegue(withIdentifier: "pushDisruptionsMonitoring", sender: self)
    }

    @objc func refreshDisruptions() {
        self.requestStatus = .loading
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetDisruptions.json",
                          method: .get,
                          parameters: ["key": API.tpg])
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    let json = try? jsonDecoder.decode(DisruptionsGroup.self, from: data)
                    self.disruptions = json
                    self.requestStatus = json?.disruptions.count ?? 0 == 0 && self.devDisruptions?.count ?? 0 == 0 ? .noResults : .ok
                    self.tableView.reloadData()
                } else {
                    self.requestStatus = .error
                    self.tableView.reloadData()
                }
                self.refreshControl?.endRefreshing()
        }
        Alamofire.request("https://tpg.asmartcode.com/disruptions.json", method: .get)
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    let json = try? jsonDecoder.decode([String: [DevDisruption]].self, from: data)
                    self.devDisruptions = json
                    self.requestStatus = json?.count ?? 0 == 0 && self.disruptions?.disruptions.count ?? 0 == 0 ? .noResults : .ok
                    self.tableView.reloadData()
                } else {
                    self.requestStatus = .error
                    self.tableView.reloadData()
                }
                self.refreshControl?.endRefreshing()
        }
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if requestStatus == .loading {
            return 1
        } else if requestStatus == .noResults {
            return 1
        } else {
            return (self.devDisruptions?.count ?? 0) + (disruptions?.disruptions.count ?? 0)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestStatus == .loading {
            return 4
        } else if requestStatus == .noResults {
            return 1
        } else {
            if section > ((self.devDisruptions?.count ?? 0) - 1) {
                return disruptions?.disruptions[self.keys[section - (self.devDisruptions?.count ?? 0)]]?.count ?? 0
            } else {
                return (self.devDisruptions?[[String](self.devDisruptions!.keys)[section]]!.count)!
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "disruptionsCell",
            for: indexPath) as? DisruptionTableViewCell else {
                return UITableViewCell()
        }

        if requestStatus == .noResults {
            cell.titleLabel.text = "No disruptions".localized
            cell.descriptionLabel?.text = "Fortunately, there is no disruptions at this time.".localized
            cell.loading = false
            cell.titleLabel.backgroundColor = App.cellBackgroundColor
            cell.descriptionLabel.backgroundColor = App.cellBackgroundColor
            cell.titleLabel.textColor = App.textColor
            cell.descriptionLabel.textColor = App.textColor
            cell.backgroundColor = App.cellBackgroundColor
            
            return cell
        } else if requestStatus == .ok {
            if indexPath.section > ((self.devDisruptions?.count ?? 0) - 1) {
                cell.disruption = disruptions?.disruptions[self.keys[indexPath.section - (self.devDisruptions?.count ?? 0)]]?[indexPath.row]
            } else {
                cell.devDisruption = self.devDisruptions?[[String](self.devDisruptions!.keys)[indexPath.section]]![indexPath.row]
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return requestStatus == .noResults ? 0 : 44
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "disruptionsHeader")

        if requestStatus == .noResults {
            return nil
        }

        headerCell?.textLabel?.text = "Loading".localized
        headerCell?.textLabel?.textColor = App.textColor

        if requestStatus != .loading {
            if section > ((self.devDisruptions?.count ?? 0) - 1) {
                let lineColor = App.color(for: (self.keys[section - (self.devDisruptions?.count ?? 0)]))
                headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : lineColor
                headerCell?.textLabel?.text = String(format: "Line %@".localized, "\(self.keys[section - (self.devDisruptions?.count ?? 0)])")
                headerCell?.textLabel?.textColor = App.darkMode ? lineColor :
                    headerCell?.backgroundColor?.contrast
            } else {
                headerCell?.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
                headerCell?.textLabel?.text = [String](self.devDisruptions!.keys)[section]
                headerCell?.textLabel?.textColor = App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white
            }
        }
        return headerCell
    }
}
