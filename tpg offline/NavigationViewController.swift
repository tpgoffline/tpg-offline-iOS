//
//  NavigationViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 10/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
  
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
    
    navigationBar.barTintColor = App.cellBackgroundColor
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
