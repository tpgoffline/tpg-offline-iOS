//
//  FavoriteRouteTableViewCell.swift
//  tpg offline
//
//  Created by Remy on 24/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class FavoriteRouteTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let route = self.route else { return 0 }
    return (route.via ?? []).count + 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
      as? FavoriteRouteSubTableViewCell else {
      return UITableViewCell()
    }
    if indexPath.row == 0 {
      cell.label.text = route?.from?.name ?? ""
      cell.icon.image = #imageLiteral(resourceName: "firstStep").maskWith(color: App.textColor)
    } else if indexPath.row == (route?.via ?? []).count + 1 {
      cell.label.text = route?.to?.name ?? ""
      cell.icon.image = #imageLiteral(resourceName: "endStep").maskWith(color: App.textColor)
    } else {
      cell.icon.image = #imageLiteral(resourceName: "middleStep").maskWith(color: App.textColor)
      if let via = (route?.via ?? [])[safe: indexPath.row - 1] {
        cell.label.text = via.name
      }
    }
    cell.label.textColor = App.textColor
    cell.backgroundColor = .clear
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 30
  }
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!

  var route: Route? = nil {
    didSet {
      guard let route = route else { return }
      
      self.tableView.reloadData()

      if App.darkMode {
        let selectedView = UIView()
        selectedView.backgroundColor = .black
        self.selectedBackgroundView = selectedView
      } else {
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white.darken(by: 0.1)
        self.selectedBackgroundView = selectedView
      }
      
      heightConstraint.constant = CGFloat(60 + ((route.via ?? []).count * 30))
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }
}

class FavoriteRouteSubTableViewCell: UITableViewCell {
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var label: UILabel!
}
