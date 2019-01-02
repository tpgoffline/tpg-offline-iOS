//
//  RoutePreviewRow.swift
//  tpg offline beta
//
//  Created by Rémy on 13/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class RoutePreviewRow: UIView {
  @IBOutlet weak var stopNameLabel: UILabel!
  @IBOutlet weak var directionLabel: UILabel!
  @IBOutlet weak var lineLabel: UILabel!
  @IBOutlet weak var lineBackgroundView: UIView!
  @IBOutlet weak var hourLabel: UILabel!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var pathImageView: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
    Bundle.main.loadNibNamed("RoutePreviewRow", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
}
