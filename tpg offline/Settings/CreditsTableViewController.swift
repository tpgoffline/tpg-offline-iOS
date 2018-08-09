//
//  CreditsTableViewController.swift
//  tpg offline
//
//  Created by Remy on 21/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import SafariServices
import Crashlytics

class CreditsTableViewController: UITableViewController {

  var credits: [[Credit]] = []
  var titles: [String] = [
    Text.atCoreOfProject,
    Text.specialThanks,
    Text.dataProviders,
    Text.externalProject
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    App.log("Show credits")
    App.logEvent("Show credits")

    credits.append([
      Credit(title: Text.remy, subTitle: Text.designAndDevelopement) { (_) in
        let vc = SFSafariViewController(url: URL(string: URL.asmartcode)!,
                                        entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
          vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        self.present(vc, animated: true)
      },
      Credit(title: Text.cedric, subTitle: Text.testing) { (_) in
        let vc = SFSafariViewController(url: URL(string: URL.dacostafaro)!,
                                        entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
          vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        self.present(vc, animated: true)
      }])
    credits.append([
      Credit(title: Text.snotpg, subTitle: Text.linesHistory) { (_) in
        let vc = SFSafariViewController(url: URL(string: URL.snotpg)!,
                                        entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
          vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        self.present(vc, animated: true)
      }])
    credits.append([
      Credit(title: Text.tpgOpenData,
             subTitle: Text.tpgOpenDataDescription) { (_) in
              let vc = SFSafariViewController(url: URL(string: URL.openData)!,
                                              entersReaderIfAvailable: false)
              if App.darkMode, #available(iOS 10.0, *) {
                vc.preferredBarTintColor = .black
              }
              vc.delegate = self

              self.present(vc, animated: true)
      },
      Credit(title: Text.sbb, subTitle: Text.sbbDescription) { (_) in
        let vc = SFSafariViewController(url: URL(string: URL.gtfs)!,
                                        entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
          vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        self.present(vc, animated: true)
      },
      Credit(title: Text.transportApi, subTitle: Text.routes) { (_) in
        let vc = SFSafariViewController(url: URL(string: URL.transportApi)!,
                                        entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
          vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        self.present(vc, animated: true)
      }
      ])
    credits.append([
      Credit(title: "Alamofire",
             subTitle: Text.alamofireDescription) { (_) in
              let vc = SFSafariViewController(url: URL(string: URL.alamofire)!,
                                              entersReaderIfAvailable: false)
              if App.darkMode, #available(iOS 10.0, *) {
                vc.preferredBarTintColor = .black
              }
              vc.delegate = self

              self.present(vc, animated: true)
      },
      Credit(title: "Fabric",
             subTitle: Text.fabricDescription) { (_) in
              let vc = SFSafariViewController(url: URL(string: URL.fabric)!,
                                              entersReaderIfAvailable: false)
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
    ColorModeManager.shared.addColorModeDelegate(self)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return credits.count
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return credits[section].count
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    let credit = credits[indexPath.section][indexPath.row]
    credit.action(credit)
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "creditCell", for: indexPath)

    cell.backgroundColor = App.cellBackgroundColor
    cell.textLabel?.textColor = App.textColor
    cell.detailTextLabel?.textColor = App.textColor
    cell.textLabel?.numberOfLines = 0
    cell.detailTextLabel?.numberOfLines = 0
    cell.textLabel?.text = credits[indexPath.section][indexPath.row].title
    cell.detailTextLabel?.text =
      credits[indexPath.section][indexPath.row].subTitle
    cell.accessoryType = .disclosureIndicator

    return cell
  }

  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
    headerCell?.backgroundColor = App.darkMode ? .black : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
    headerCell?.textLabel?.text = titles[section]
    headerCell?.textLabel?.textColor = App.darkMode ?
      #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : headerCell?.backgroundColor?.contrast

    return headerCell
  }

  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
}

extension CreditsTableViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true)
  }
}

struct Credit {
  var title: String = ""
  var subTitle: String = ""
  var action: ((Credit) -> Void)!
}
