//
//  DisruptionsTableViewController.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 18/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit
import Alamofire

class DisruptionsTableViewController: UITableViewController {

    var disruptions: DisruptionsGroup?
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

    override func viewDidLoad() {
        super.viewDidLoad()

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
                          parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b"])
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    let json = try? jsonDecoder.decode(DisruptionsGroup.self, from: data)
                    self.requestStatus = json?.disruptions.count ?? 0 == 0 ? .noResults : .ok
                    self.disruptions = json
                    self.tableView.reloadData()
                } else {
                    /*self.requestStatus = .error
                    self.tableView.reloadData()*/
                }
                self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if requestStatus == .loading {
            return 1
        } else {
            return disruptions?.disruptions.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestStatus == .loading {
            return 4
        } else {
            return disruptions?.disruptions[disruptions!.disruptions.keys.sorted()[section]]?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "disruptionsCell",
            for: indexPath) as? DisruptionTableViewCell else {
                return UITableViewCell()
        }

        if requestStatus == .ok {
            cell.disruption = disruptions?.disruptions[disruptions!.disruptions.keys.sorted()[indexPath.section]]?[indexPath.row]
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "disruptionsHeader")

        headerCell?.textLabel?.text = "Loading".localized
        headerCell?.textLabel?.textColor = App.textColor

        if requestStatus != .loading && requestStatus != .noResults {
            headerCell?.backgroundColor = App.linesColor.filter({$0.line == (disruptions!.disruptions.keys.sorted()[section])})[safe:
                0]?.color ?? .white
            headerCell?.textLabel?.text = String(format: "Line %@".localized, "\(disruptions!.disruptions.keys.sorted()[section])")
            headerCell?.textLabel?.textColor = headerCell?.backgroundColor?.contrast
        }
        return headerCell
    }
}
