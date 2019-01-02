//
//  DisruptionsMananger.swift
//  tpg offline beta
//
//  Created by Rémy on 23/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import Foundation
import Alamofire

class DisruptionsMananger {
  private(set) var disruptions: DisruptionsGroup? {
    didSet {
      App.log(disruptions?.disruptions.debugDescription ?? "")
    }
  }
  private(set) var status: RequestStatus {
    didSet {
      self.delegates.forEach({ $0.disruptionsDidChange() })
    }
  }
  
  static let shared = DisruptionsMananger()
  
  private var delegates = [DisruptionsDelegate]()
  
  init() {
    disruptions = nil
    status = .loading
    self.refresh()
    
    _ = Timer.scheduledTimer(timeInterval: 180,
                             target: self,
                             selector: #selector(refresh),
                             userInfo: nil,
                             repeats: true)
  }
  
  @objc func refresh() {
    status = .loading
    Alamofire.request(URL.disruptions,
                      method: .get,
                      parameters: ["key": API.tpg])
      .responseData { (response) in
        if let data = response.result.value {
          let jsonDecoder = JSONDecoder()
          let json = try? jsonDecoder.decode(DisruptionsGroup.self,
                                             from: data)
          self.disruptions = json
          self.status =
            (json?.disruptions.count ?? 0 == 0) ? .noResults : .ok
        } else {
          self.status = .error
        }
    }
  }
  
  func add<T>(_ delegate: T) where
    T: DisruptionsDelegate, T: Equatable {
      delegates.append(delegate)
  }
  
  func remove<T>(_ delegate: T) where
    T: DisruptionsDelegate, T: Equatable {
      for (index, delegate) in delegates.enumerated() {
        if let delegate = delegate as? T,
          delegate == delegate {
          delegates.remove(at: index)
          break
        }
      }
  }
}

protocol DisruptionsDelegate {
  func disruptionsDidChange()
}
