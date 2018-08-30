//
//  MapsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/10/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class OrientationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  var maps: [String: UIImage] = [
    Text.urbanMap: #imageLiteral(resourceName: "urbainMap"),
    Text.regionalMap: #imageLiteral(resourceName: "periurbainMap"),
    Text.noctambusUrbanMap: #imageLiteral(resourceName: "nocUrbainMap"),
    Text.noctambusRegionalMap: #imageLiteral(resourceName: "nocPeriurbainMap")
  ]

  var titles = [
    Text.urbanMap,
    Text.regionalMap,
    Text.noctambusUrbanMap,
    Text.noctambusRegionalMap
  ]
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()

    title = Text.orientation
    if App.darkMode {
      self.navigationController?.navigationBar.barStyle = .black
      self.tableView.backgroundColor = .black
    } else {
      self.navigationController?.navigationBar.barStyle = .default
    }

    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }

    segmentedControl.setTitle(Text.lines, forSegmentAt: 0)
    segmentedControl.setTitle(Text.map, forSegmentAt: 1)
    segmentedControl.selectedSegmentIndex = 0
    ColorModeManager.shared.addColorModeDelegate(self)
    
    self.tableView.backgroundColor = App.darkMode ? .black :
      .groupTableViewBackground
    self.view.backgroundColor = App.darkMode ? .black :
      .groupTableViewBackground
    self.tableView.separatorColor = App.separatorColor
    self.tableView.reloadData()
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.tableView.backgroundColor = App.darkMode ? .black :
      .groupTableViewBackground
    self.tableView.separatorColor = App.separatorColor
    self.tableView.reloadData()
  }
  // MARK: - Table view data source

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return segmentedControl.selectedSegmentIndex == 1 ? maps.count : App.lines.count
  }

  func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if segmentedControl.selectedSegmentIndex == 1 {
      guard let cell =
        tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath)
          as? MapsTableViewControllerRow else {
        return UITableViewCell()
      }

      cell.titleLabel.text = titles[indexPath.row]
      cell.mapImage = self.maps[titles[indexPath.row]]

      return cell
    } else {
      guard let cell =
        tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath)
          as? LineTableViewControllerRow else {
        return UITableViewCell()
      }
      cell.line = App.lines[indexPath.row]
      cell.accessoryType = .disclosureIndicator
      return cell
    }
  }

  func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
    if segmentedControl.selectedSegmentIndex == 1 {
      return 190
    } else {
      return UITableViewAutomaticDimension
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showMap" {
      guard let destinationViewController =
        segue.destination as? MapViewController else { return }
      guard let indexPath = tableView.indexPathForSelectedRow else { return }
      guard let row =
        tableView.cellForRow(at: indexPath) as? MapsTableViewControllerRow else {
          return
      }
      tableView.deselectRow(at: indexPath, animated: false)
      destinationViewController.mapImage = row.mapImage
      destinationViewController.title = row.titleLabel.text
    } else if segue.identifier == "showLine" {
      guard let destinationViewController = segue.destination as? LineViewController
        else { return }
      guard let indexPath = tableView.indexPathForSelectedRow else { return }
      guard let row = tableView.cellForRow(at: indexPath)
        as? LineTableViewControllerRow else { return }
      tableView.deselectRow(at: indexPath, animated: false)
      destinationViewController.line = row.line
    }
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
  
  @IBAction func setTableViewContent() {
    self.tableView.reloadData()
    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
  }
}

extension OrientationTableViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    //swiftlint:disable:previous line_length

    guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

    if segmentedControl.selectedSegmentIndex == 1 {
      guard let row = tableView.cellForRow(at: indexPath)
        as? MapsTableViewControllerRow else { return nil }
      guard let detailVC = storyboard?
        .instantiateViewController(withIdentifier: "mapViewController")
        as? MapViewController else { return nil }
      detailVC.mapImage = row.mapImage
      detailVC.title = row.titleLabel.text
      previewingContext.sourceRect = row.frame
      return detailVC
    } else {
      guard let row = tableView.cellForRow(at: indexPath)
        as? LineTableViewControllerRow else { return nil }
      guard let detailVC = storyboard?
        .instantiateViewController(withIdentifier: "lineViewController")
        as? LineViewController else { return nil }
      detailVC.line = row.line
      previewingContext.sourceRect = row.frame
      return detailVC
    }
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
}

class MapsTableViewControllerRow: UITableViewCell {
  @IBOutlet private weak var mapImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var visualEffectView: UIVisualEffectView!

  var mapImage: UIImage? {
    get {
      return mapImageView.image
    } set {
      mapImageView.image = newValue
      self.titleLabel.textColor = App.textColor
      self.visualEffectView.effect =
        UIBlurEffect(style: App.darkMode ? .dark : .light)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    let view = UIView()
    view.backgroundColor = .clear
    self.selectedBackgroundView = view
  }
}

class LineTableViewControllerRow: UITableViewCell {
  var line: Line? {
    didSet {
      guard let line = self.line else { return }
      self.textLabel?.text = Text.line(line.line)
      self.detailTextLabel?.text = String(format: "%@ ↔︎ %@", line.departureName, line.arrivalName)
      if App.darkMode {
        self.backgroundColor = App.cellBackgroundColor
        self.textLabel?.textColor = App.color(for: line.line)
        self.detailTextLabel?.textColor = App.color(for: line.line)
      } else {
        self.backgroundColor = App.color(for: line.line)
        self.textLabel?.textColor = App.color(for: line.line).contrast
        self.detailTextLabel?.textColor = App.color(for: line.line).contrast
      }
      self.tintColor = self.textLabel?.textColor
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    let view = UIView()
    view.backgroundColor = .clear
    self.selectedBackgroundView = view
  }
}
