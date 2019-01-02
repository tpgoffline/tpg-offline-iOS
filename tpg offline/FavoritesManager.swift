//
//  FavoritesManager.swift
//  tpg offline beta
//
//  Created by Rémy on 15/12/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import Foundation

class FavoritesManager {
  var stops: [Int] {
    get {
      return (UserDefaults.standard.object(forKey: "favoritesStops") as? [Int]) ?? []
    } set {
      UserDefaults.standard.set(newValue, forKey: "favoritesStops")
      #if os(iOS)
      App.watchSessionManager.sync()
      #endif
      self.delegates.forEach({ $0.updateFavorite() })
    }
  }
  
  static let shared = FavoritesManager()
  
  private var delegates = [FavoritesDelegate]()
  
  init() {
  }
  
  func add<T>(_ delegate: T) where
    T: FavoritesDelegate, T: Equatable {
      delegates.append(delegate)
  }
  
  func remove<T>(_ delegate: T) where
    T: FavoritesDelegate, T: Equatable {
      for (index, delegate) in delegates.enumerated() {
        if let delegate = delegate as? T,
          delegate == delegate {
          delegates.remove(at: index)
          break
        }
      }
  }
}

protocol FavoritesDelegate {
  func updateFavorite()
}
