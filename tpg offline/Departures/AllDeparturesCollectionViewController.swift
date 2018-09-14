//
//  AllDeparturesCollectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 01/10/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Alamofire

class AllDeparturesCollectionViewController: UICollectionViewController {

  var departure: Departure?
  var stop: Stop?
  var departuresList: DeparturesGroup?
  var hours: [Int] = []

  var loading = false {
    didSet {
      self.collectionView?.reloadData()
    }
  }

  var refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = String(format: "Line %@".localized, "\(departure?.line.code ?? "#!?")")

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                      style: UIBarButtonItem.Style.plain,
                      target: self,
                      action: #selector(self.refresh),
                      accessbilityLabel: "Reload".localized)
    ]

    self.refreshControl = UIRefreshControl()
    if #available(iOS 10.0, *) {
      collectionView?.refreshControl = refreshControl
    } else {
      collectionView?.addSubview(refreshControl)
    }

    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    refreshControl.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

    if App.darkMode {
      collectionView?.backgroundColor = App.cellBackgroundColor
    }

    ColorModeManager.shared.addColorModeDelegate(self)

    refresh()
  }

  @objc func refresh() {
    guard let stop = self.stop,
      let departure = self.departure else { return }
    loading = true
    let destinationCode = departure.line.destinationCode
    Alamofire.request(URL.allNextDepartures,
                      method: .get,
                      parameters: ["key": API.tpg,
                                   "stopCode": stop.code,
                                   "lineCode": departure.line.code,
                                   "destinationCode": destinationCode])
      .responseData { (response) in
        if let data = response.result.value {
          var options = DeparturesOptions()
          options.networkStatus = .online
          let jsonDecoder = JSONDecoder()
          jsonDecoder.userInfo = [ DeparturesOptions.key: options ]

          do {
            let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
            self.departuresList = json
          } catch {
            self.loading = false
            self.refreshControl.endRefreshing()
            return
          }

          self.hours = self.departuresList?.departures.map({
            $0.dateCompenents?.hour ?? 0
          }).uniqueElements ?? []
          self.hours.sort()
          self.loading = false
          self.refreshControl.endRefreshing()
        }
    }
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    if loading {
      return 1
    } else {
      return self.hours.count
    }
  }

  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    if loading {
      return 5
    } else {
      return self.departuresList?.departures.filter({
        $0.dateCompenents?.hour == self.hours[section]
      }).count ?? 0
    }
  }

  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // swiftlint:disable:previous line_length
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
      "allDeparturesCell", for: indexPath) as? AllDeparturesCollectionViewCell else {
        return UICollectionViewCell()
    }

    if !loading {
      cell.departure = self.departuresList?.departures.filter({
        $0.dateCompenents?.hour == self.hours[indexPath.section]
      })[indexPath.row]
    }

    return cell
  }

  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    if loading {
      let cellId = "allDeparturesHeader"
      guard let headerView = collectionView
        .dequeueReusableSupplementaryView(ofKind: kind,
                                                  withReuseIdentifier: cellId,
                                                  for: indexPath)
        as? AllDeparturesHeader else {
          return UICollectionViewCell()
      }
      headerView.backgroundColor = App.darkMode ? .black : #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
      headerView.title.text = ""
      return headerView
    } else {
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let cellId = "allDeparturesHeader"
        guard let headerView = collectionView
          .dequeueReusableSupplementaryView(ofKind: kind,
                                            withReuseIdentifier: cellId,
                                            for: indexPath)
          as? AllDeparturesHeader else {
            return UICollectionViewCell()
        }
        var dateComponents = DateComponents()
        let dateFormatter = DateFormatter()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = self.hours[indexPath.section]
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        headerView.title.text = dateFormatter.string(from:
          dateComponents.date ?? Date())
        headerView.title.accessibilityLabel = dateFormatter.string(from:
          dateComponents.date ?? Date())
        headerView.backgroundColor = App.darkMode ? .black : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        headerView.title.textColor = App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white

        return headerView
      default:
        assert(false, "Unexpected element kind")
        return UICollectionReusableView()
      }
    }
  }
}

class AllDeparturesHeader: UICollectionReusableView {
  @IBOutlet weak var title: UILabel!
}
