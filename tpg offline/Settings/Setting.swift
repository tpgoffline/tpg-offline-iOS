//
//  Setting.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/08/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

struct Setting {
  var title: String
  var icon: UIImage
  var action: ((Setting) -> Void)!

  init(_ title: String, icon: UIImage, action: ((Setting) -> Void)!) {
    self.title = title
    self.icon = icon
    self.action = action
  }
}
