//
//  Setting.swift
//  tpg offline
//
//  Created by Remy on 16/08/2017.
//  Copyright © 2017 Remy. All rights reserved.
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
