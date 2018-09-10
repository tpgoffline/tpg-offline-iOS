//
//  DisruptionsTableViewController.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 18/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

class DisruptionsTableViewController: UITableViewController {

  @IBOutlet weak var disruptionsCenteredView: DisruptionsCenteredView!

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
        self.disruptionsCenteredView.imageView.image = #imageLiteral(resourceName: "errorHighRes").maskWith(color:
          App.textColor)
        self.disruptionsCenteredView.titleLabel.textColor = App.textColor
        self.disruptionsCenteredView.titleLabel.text = Text.error
        self.disruptionsCenteredView.subtitleLabel.text = Text.errorNoInternet
        self.disruptionsCenteredView.subtitleLabel.textColor = App.textColor
        self.disruptionsCenteredView.isHidden = false
        self.tableView.separatorStyle = .none
      } else if requestStatus == .noResults {
        self.disruptionsCenteredView.imageView.image = #imageLiteral(resourceName: "sunHighRes").maskWith(color:
          App.textColor)
        self.disruptionsCenteredView.titleLabel.text = Text.noDisruptions
        self.disruptionsCenteredView.titleLabel.textColor = App.textColor
        self.disruptionsCenteredView.subtitleLabel.text = Text.noDisruptionsSubtitle
        self.disruptionsCenteredView.subtitleLabel.textColor = App.textColor
        self.disruptionsCenteredView.isHidden = false
        self.tableView.separatorStyle = .none
      } else {
        self.disruptionsCenteredView.isHidden = true
        self.tableView.separatorStyle = .singleLine
      }
    }
  }

  var keys: [String] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    App.logEvent("Show disruptions", attributes: [:])

    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 140
    tableView.allowsSelection = false

    //disruptionsCenteredView.center = tableView.center
    disruptionsCenteredView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(disruptionsCenteredView)
    NSLayoutConstraint.activate([
      disruptionsCenteredView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: 16),
      disruptionsCenteredView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: 16)
      ])
    disruptionsCenteredView.centerXAnchor
      .constraint(equalTo: self.tableView.centerXAnchor).isActive = true
    disruptionsCenteredView.centerYAnchor
      .constraint(equalTo: self.tableView.centerYAnchor).isActive = true
    disruptionsCenteredView.isHidden = true

    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
      navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.foregroundColor: App.textColor]
    }

    navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedString.Key.foregroundColor: App.textColor]

    self.refreshDisruptions()

    refreshControl = UIRefreshControl()

    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      tableView.addSubview(refreshControl!)
    }

    refreshControl?.addTarget(self,
                              action: #selector(refreshDisruptions),
                              for: .valueChanged)
    refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: #imageLiteral(resourceName: "binoculars"),
                      style: .plain,
                      target: self,
                      action: #selector(self.pushDisruptionsMonitoring),
                      accessbilityLabel: Text.disruptionsMonitoring),
      UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.refreshDisruptions),
                      accessbilityLabel: Text.reloadDepartures)
    ]
    if App.darkMode {
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.backgroundColor = .black
      self.tableView.separatorColor = App.separatorColor
    }

    self.tableView.sectionIndexBackgroundColor = App.darkMode ?
      App.cellBackgroundColor : .white

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.disruptionsCenteredView.titleLabel.textColor = App.textColor
    self.disruptionsCenteredView.subtitleLabel.textColor = App.textColor
    self.disruptionsCenteredView.imageView.image =
      self.disruptionsCenteredView.imageView.image?.maskWith(color: App.textColor)
  }

  @objc func pushDisruptionsMonitoring() {
    performSegue(withIdentifier: "pushDisruptionsMonitoring", sender: self)
  }

  @objc func refreshDisruptions() {
    self.requestStatus = .loading
    self.tableView.reloadData()
    Alamofire.request(URL.disruptions,
                      method: .get,
                      parameters: ["key": API.tpg])
      .responseData { (response) in
        if let data = response.result.value {
          let jsonDecoder = JSONDecoder()
          let json = try? jsonDecoder.decode(DisruptionsGroup.self,
                                             from: data)
          self.disruptions = json
          self.requestStatus =
            (json?.disruptions.count ?? 0 == 0) ? .noResults : .ok
          self.tableView.reloadData()
        } else {
          self.requestStatus = .error
          self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()

        // Warning: Ugly code ahead
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
          self.tableView.reloadData()
        })
        // End of warning
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
      return 0
    } else {
      return (disruptions?.disruptions.count ?? 0)
    }
  }

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    #if swift(>=4.1)
    return self.keys.compactMap({ $0.count > 4 ? "/" : $0 })
    #else
    return self.keys.flatMap({ $0.count > 4 ? "/" : $0 })
    #endif
  }

  override func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int {
    return index
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if requestStatus == .loading {
      return 3
    } else {
      return disruptions?.disruptions[self.keys[section]]?.count ?? 0
    }
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "disruptionsCell",
      for: indexPath) as? DisruptionTableViewCell else {
        return UITableViewCell()
    }

    if requestStatus == .ok {
      let key = self.keys[indexPath.section]
      cell.disruption = disruptions?.disruptions[key]?[indexPath.row]
      cell.lines = self.keys[indexPath.section] == Text.wholeTpgNetwork ?
        ["tpg"] : self.keys[indexPath.section].components(separatedBy: " / ")
    } else {
      cell.disruption = nil
    }

    return cell
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    // swiftlint:disable:previous line_length
    // Warning: Ugly code ahead
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
      self.tableView.reloadData()
    })
    // End of warning
  }
}

class DisruptionsCenteredView: UIView {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
}
