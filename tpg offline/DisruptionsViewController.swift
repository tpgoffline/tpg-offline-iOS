//
//  DisruptionsViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 16/12/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class DisruptionsViewController: TableViewController, DisruptionsDelegate, UITableViewDataSource {
  
  @IBOutlet weak var disruptionsCenteredView: DisruptionsCenteredView!
  var keys: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    DisruptionsMananger.shared.add(self)
    self.disruptionsDidChange()
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 140
    tableView.allowsSelection = false
    
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
    
    self.tableView.sectionIndexBackgroundColor = App.darkMode ?
      App.cellBackgroundColor : .white
  }
  
  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.disruptionsCenteredView.titleLabel.textColor = App.textColor
    self.disruptionsCenteredView.subtitleLabel.textColor = App.textColor
    self.disruptionsCenteredView.imageView.image =
      self.disruptionsCenteredView.imageView.image?.colorize(with: App.textColor)
  }
  
  func disruptionsDidChange() {
    switch DisruptionsMananger.shared.status {
    case .error:
      self.disruptionsCenteredView.imageView.image = #imageLiteral(resourceName: "warning").colorize(with:
        App.textColor)
      self.disruptionsCenteredView.titleLabel.textColor = App.textColor
      self.disruptionsCenteredView.titleLabel.text = Text.error
      self.disruptionsCenteredView.subtitleLabel.text = Text.errorNoInternet
      self.disruptionsCenteredView.subtitleLabel.textColor = App.textColor
      self.disruptionsCenteredView.isHidden = false
      self.tableView.separatorStyle = .none
    case .noResults:
      self.disruptionsCenteredView.imageView.image = #imageLiteral(resourceName: "sun").colorize(with:
        App.textColor)
      self.disruptionsCenteredView.titleLabel.text = Text.noDisruptions
      self.disruptionsCenteredView.titleLabel.textColor = App.textColor
      self.disruptionsCenteredView.subtitleLabel.text = Text.noDisruptionsSubtitle
      self.disruptionsCenteredView.subtitleLabel.textColor = App.textColor
      self.disruptionsCenteredView.isHidden = false
      self.tableView.separatorStyle = .none
    default:
      self.disruptionsCenteredView.isHidden = true
      self.tableView.separatorStyle = .singleLine
    }
    
    guard let disruptions = DisruptionsMananger.shared.disruptions else { return }
    self.keys = disruptions.disruptions.keys.sorted(by: {
      if let a = Int($0), let b = Int($1) {
        return a < b
      } else { return $0 < $1 }})
    
    self.tableView.reloadData()
    // Warning: Ugly code ahead
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
      self.tableView.reloadData()
    })
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if DisruptionsMananger.shared.status == any(of: .loading, .noResults) {
      return 0
    } else {
      return (DisruptionsMananger.shared.disruptions?.disruptions.count ?? 0)
    }
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.keys.compactMap({ $0.count > 4 ? "/" : $0 })
  }
  
  func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int {
    return index
  }
  
  func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return DisruptionsMananger.shared.disruptions?.disruptions[self.keys[section]]?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "disruptionsCell",
      for: indexPath) as? DisruptionTableViewCell else {
        return UITableViewCell()
    }
    
    if DisruptionsMananger.shared.status == .ok {
      let key = self.keys[indexPath.section]
      cell.disruption = DisruptionsMananger.shared.disruptions?.disruptions[key]?[indexPath.row]
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
  
  deinit {
    DisruptionsMananger.shared.remove(self)
  }
}

class DisruptionsCenteredView: UIView {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
}
