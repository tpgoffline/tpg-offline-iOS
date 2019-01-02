//
//  DrawerContainerViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 07/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class DrawerContainerViewController: UIViewController {
  
  @IBOutlet weak var handleView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ColorModeManager.shared.add(self)
    colorModeDidUpdated()
  }
  
  deinit {
    ColorModeManager.shared.remove(self)
  }
  
  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    handleView.backgroundColor = App.darkMode ? UIColor.handleDark : UIColor.handleLight
  }
}
