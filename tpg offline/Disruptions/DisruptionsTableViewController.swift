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
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.refreshDisruptions))
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func refreshDisruptions() {
        self.requestStatus = .loading
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetDisruptions.json",
                          method: .get,
                          parameters: ["key": API.key])
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    let json = try? jsonDecoder.decode(DisruptionsGroup.self, from: data)
                    self.requestStatus = json?.disruptions.count ?? 0 == 0 ? .noResults : .ok
                    self.disruptions = json
                    self.tableView.reloadData()
                } else {
                    self.requestStatus = .error
                    self.tableView.reloadData()
                }
                self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if requestStatus == .loading {
            return 1
        } else if requestStatus == .noResults {
            return 1
        } else {
            return disruptions?.disruptions.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestStatus == .loading {
            return 4
        } else if requestStatus == .noResults {
            return 1
        } else {
            return disruptions?.disruptions[self.keys[section]]?.count ?? 0
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
            cell.titleLabel.backgroundColor = .white
            cell.descriptionLabel.backgroundColor = .white
            cell.titleLabel.textColor = App.textColor
            cell.descriptionLabel.textColor = App.textColor
        } else if requestStatus == .ok {
            cell.disruption = disruptions?.disruptions[self.keys[indexPath.section]]?[indexPath.row]
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
            headerCell?.backgroundColor = App.linesColor.filter({$0.line == (self.keys[section])})[safe:
                0]?.color ?? .white
            headerCell?.textLabel?.text = String(format: "Line %@".localized, "\(self.keys[section])")
            headerCell?.textLabel?.textColor = headerCell?.backgroundColor?.contrast
        }
        return headerCell
    }
}
