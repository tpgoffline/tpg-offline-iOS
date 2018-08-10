//
//  NewFeaturesTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 23/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class NewFeaturesTableViewCell: UITableViewCell {

  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!

  var feature: Feature? {
    didSet {
      guard let feature = self.feature else { return }
      self.iconImageView.image = feature.image.maskWith(color: App.textColor)
      self.titleLabel.text = feature.title
      self.titleLabel.textColor = App.textColor
      self.descriptionLabel.text = feature.text
      self.descriptionLabel.textColor = App.textColor
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = App.cellBackgroundColor
  }
}
