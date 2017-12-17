//
//  CreditsTableViewController.swift
//  tpg offline
//
//  Created by Remy on 21/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import SafariServices

class CreditsTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    var credits: [[Credit]] = []
    var titles: [String] = [
        "At the core of the project".localized,
        "Special thanks".localized,
        "Data providers".localized,
        "External libraries, used in this project".localized
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        credits.append([
            Credit(title: "Rémy Da Costa Faro".localized, subTitle: "Design and developement".localized) { (_) in
                let vc = SFSafariViewController(url: URL(string: "https://asmartcode.com")!, entersReaderIfAvailable: false)
                if App.darkMode, #available(iOS 10.0, *) {
                    vc.preferredBarTintColor = .black
                }
                vc.delegate = self

                self.present(vc, animated: true)
            },
            Credit(title: "Cédric Da Costa Faro".localized, subTitle: "Testing".localized) { (_) in
                let vc = SFSafariViewController(url: URL(string: "http://dacostafaro.com")!, entersReaderIfAvailable: false)
                if App.darkMode, #available(iOS 10.0, *) {
                    vc.preferredBarTintColor = .black
                }
                vc.delegate = self

                self.present(vc, animated: true)
            }])
        credits.append([
            Credit(title: "SNOTPG".localized, subTitle: "Lines history and moral and material support".localized) { (_) in
                let vc = SFSafariViewController(url: URL(string: "https://www.snotpg.ch/site/")!, entersReaderIfAvailable: false)
                if App.darkMode, #available(iOS 10.0, *) {
                    vc.preferredBarTintColor = .black
                }
                vc.delegate = self

                self.present(vc, animated: true)
            }])
        credits.append([
            Credit(title: "Open data of Geneva public transport".localized, subTitle: "Departures, Disruptions and Maps".localized) { (_) in
                let vc = SFSafariViewController(url: URL(string: "http://www.tpg.ch/web/open-data/")!, entersReaderIfAvailable: false)
                if App.darkMode, #available(iOS 10.0, *) {
                    vc.preferredBarTintColor = .black
                }
                vc.delegate = self

                self.present(vc, animated: true)
            },
            Credit(title: "Open data of Transport API".localized, subTitle: "Routes".localized) { (_) in
                let vc = SFSafariViewController(url: URL(string: "http://transport.opendata.ch")!, entersReaderIfAvailable: false)
                if App.darkMode, #available(iOS 10.0, *) {
                    vc.preferredBarTintColor = .black
                }
                vc.delegate = self

                self.present(vc, animated: true)
            }])
        credits.append([
            Credit(title: "Alamofire".localized,
                   subTitle: "Elegant HTTP Networking in Swift - https://github.com/Alamofire/Alamofire".localized) { (_) in
                    let vc = SFSafariViewController(url: URL(string: "https://github.com/Alamofire/Alamofire")!, entersReaderIfAvailable: false)
                    if App.darkMode, #available(iOS 10.0, *) {
                        vc.preferredBarTintColor = .black
                    }
                    vc.delegate = self

                    self.present(vc, animated: true)
            }])
        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return credits.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credits[section].count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credit = credits[indexPath.section][indexPath.row]
        credit.action(credit)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "creditCell", for: indexPath)

        cell.backgroundColor = App.cellBackgroundColor
        cell.textLabel?.textColor = App.textColor
        cell.detailTextLabel?.textColor = App.textColor
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = credits[indexPath.section][indexPath.row].title
        cell.detailTextLabel?.text = credits[indexPath.section][indexPath.row].subTitle

        return cell
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        headerCell?.backgroundColor = App.darkMode ? .black : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        headerCell?.textLabel?.text = titles[section]
        headerCell?.textLabel?.textColor = App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : headerCell?.backgroundColor?.contrast

        return headerCell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

}
