//
//  ColorModeManager.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 06/01/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class ColorModeManager: NSObject {
  
  fileprivate override init() {
    super.init()
    
    _ = Timer.scheduledTimer(timeInterval: 300,
                             target: self,
                             selector: #selector(checkTime),
                             userInfo: nil,
                             repeats: true)
  }
  
  @objc func checkTime() {
    if App.automaticDarkMode,
      App.sunriseSunsetManager?.isDaytime ?? false,
      App.darkMode == true {
      App.darkMode = false
    } else if App.automaticDarkMode,
      App.sunriseSunsetManager?.isNighttime ?? false,
      App.darkMode == false {
      App.darkMode = true
    }
  }
  
  static let shared = ColorModeManager()
  
  private var colorModeDelegates = [ColorModeDelegate]()
  
  func add<T>(_ delegate: T) where
    T: ColorModeDelegate, T: Equatable {
      colorModeDelegates.append(delegate)
  }
  
  func remove<T>(_ delegate: T) where
    T: ColorModeDelegate, T: Equatable {
      for (index, colorModeDelegate) in colorModeDelegates.enumerated() {
        if let colorModeDelegate = colorModeDelegate as? T,
          colorModeDelegate == delegate {
          colorModeDelegates.remove(at: index)
          break
        }
      }
  }
  
  func updateColorMode() {
    DispatchQueue.main.async {
      self.colorModeDelegates.forEach { $0.colorModeDidUpdated() }
    }
  }
}

protocol ColorModeDelegate: class {
  func colorModeDidUpdated()
}
