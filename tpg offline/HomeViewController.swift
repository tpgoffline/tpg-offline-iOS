//
//  HomeViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 07/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class HomeViewController: ScrollViewController {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var favoritesCollectionView: UICollectionView!
  @IBOutlet weak var favoritesCollectionViewHeight: NSLayoutConstraint!
  @IBOutlet weak var disruptionsCollectionView: UICollectionView!
  @IBOutlet weak var disruptionsCollectionViewHeight: NSLayoutConstraint!
  @IBOutlet weak var disruptionsAccessoryImageView: UIImageView!
  @IBOutlet weak var disruptionsStatusLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ColorModeManager.shared.add(self)
    
    self.favoritesCollectionView.delegate = self
    self.favoritesCollectionView.dataSource = self
    self.favoritesCollectionView.isScrollEnabled = false
    self.favoritesCollectionView.tag = 1
    
    self.disruptionsCollectionView.delegate = self
    self.disruptionsCollectionView.dataSource = self
    self.disruptionsCollectionView.isScrollEnabled = false
    self.disruptionsCollectionView.tag = 2
    
//    scrollView.addSubview(containerView)
    self.containerView.translatesAutoresizingMaskIntoConstraints = false
    
    self.containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    self.containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    self.containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    self.containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    self.containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    
    DataUpdateManager.shared.checkUpdate(viewController: self)
    
    let _ = LocationManager.shared // Init shared TimetablesManager
    let _ = TimetablesManager.shared // Init shared TimetablesManager
    let _ = DisruptionsMananger.shared // Init shared DisruptionsMananger
    
    LocationManager.shared.add(self)
    FavoritesManager.shared.add(self)
    DisruptionsMananger.shared.add(self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  
  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.favoritesCollectionView.backgroundColor = App.cellBackgroundColor
    self.favoritesCollectionView.reloadData()
    self.disruptionsCollectionView.backgroundColor = App.cellBackgroundColor
    self.disruptionsCollectionView.reloadData()
  }
  
  deinit {
    ColorModeManager.shared.remove(self)
    LocationManager.shared.remove(self)
    DisruptionsMananger.shared.remove(self)
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView.tag == 1 {
      return FavoritesManager.shared.stops.count + (LocationManager.shared.nearestStops.isEmpty ? 0 : 1)
    } else {
      return DisruptionsMananger.shared.disruptions?.disruptions.count ?? 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView.tag == 1 {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as? FavoriteStopCell else {
        return UICollectionViewCell()
      }
      if let nearestStop = LocationManager.shared.nearestStops.first, indexPath.row == 0 {
        cell.imageView.image = App.imageForStop(stop: nearestStop)
        cell.stopNameLabel.text = nearestStop.name
        cell.stopNameLabel.textColor = App.textColor
        cell.visualEffectView.effect = UIBlurEffect(style: App.darkMode ? .dark : .light)
        self.favoritesCollectionViewHeight.constant = self.favoritesCollectionView.contentSize.height
        return cell
      } else {
        let showLocation = LocationManager.shared.nearestStops.isEmpty ? 0 : 1
        guard let stop = App.stops.first(where: { $0.appId == FavoritesManager.shared.stops[indexPath.row - showLocation] }) else {
          return UICollectionViewCell()
        }
        cell.imageView.image = App.imageForStop(stop: stop)
        cell.stopNameLabel.text = stop.name
        cell.stopNameLabel.textColor = App.textColor
        cell.visualEffectView.effect = UIBlurEffect(style: App.darkMode ? .dark : .light)
        self.favoritesCollectionViewHeight.constant = self.favoritesCollectionView.contentSize.height
        return cell
      }
    } else {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "disruptionCell", for: indexPath) as? DisruptionCell else {
        return UICollectionViewCell()
      }
      
      var keys = [String]((DisruptionsMananger.shared.disruptions?.disruptions ?? [:]).keys)
      keys.sort()
      cell.lineLabel.text = keys[indexPath.row]
      cell.lineLabel.textColor = LineColorManager.color(for: keys[indexPath.row]).contrast
      cell.backgroundColor = LineColorManager.color(for: keys[indexPath.row])
      cell.layer.cornerRadius = 12.5
      self.disruptionsCollectionViewHeight.constant = self.disruptionsCollectionView.contentSize.height
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView.tag == 1 {
      if let nearestStop = LocationManager.shared.nearestStops.first, indexPath.row == 0 {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "departuresVC") as! DeparturesViewController
        vc.stop = nearestStop
        self.navigationController?.pushViewController(vc, animated: true)
      } else {
        let showLocation = LocationManager.shared.nearestStops.isEmpty ? 0 : 1
        guard let stop = App.stops.first(where: { $0.appId == FavoritesManager.shared.stops[indexPath.row - showLocation] }) else {
          return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "departuresVC") as! DeparturesViewController
        vc.stop = stop
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
}

extension HomeViewController: LocationDelegate {
  func nearestStopChanged() {
    self.favoritesCollectionView.reloadData()
  }
}

extension HomeViewController: DisruptionsDelegate {
  func disruptionsDidChange() {
    switch DisruptionsMananger.shared.status {
    case .loading:
      disruptionsStatusLabel.isHidden = false
      disruptionsCollectionView.isHidden = true
      disruptionsAccessoryImageView.isHidden = true
      disruptionsStatusLabel.text = "Loading..."
    case .ok:
      disruptionsStatusLabel.isHidden = true
      disruptionsCollectionView.isHidden = false
      disruptionsAccessoryImageView.isHidden = false
      self.disruptionsCollectionView.reloadData()
    case .error:
      disruptionsStatusLabel.isHidden = false
      disruptionsCollectionView.isHidden = true
      disruptionsAccessoryImageView.isHidden = true
      disruptionsStatusLabel.text = "An error occured when loading disruptions"
    case .noResults:
      disruptionsStatusLabel.isHidden = false
      disruptionsCollectionView.isHidden = true
      disruptionsAccessoryImageView.isHidden = true
      disruptionsStatusLabel.text = "No disruptions on the network"
    }
  }
}

extension HomeViewController: FavoritesDelegate {
  func updateFavorite() {
    self.favoritesCollectionView.reloadData()
  }
}

class FavoriteStopCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var stopNameLabel: UILabel!
  @IBOutlet weak var visualEffectView: UIVisualEffectView!
}

class DisruptionCell: UICollectionViewCell {
  @IBOutlet weak var lineLabel: UILabel!
}
