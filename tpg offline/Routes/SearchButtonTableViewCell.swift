//
//  SearchButtonTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/09/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class SearchButtonTableViewCell: UITableViewCell {

  @IBOutlet weak var button: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView?.backgroundColor = .white
  }
}
