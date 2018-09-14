//
//  DeparturesIntentHandler.swift
//  tpg offline Siri
//
//  Created by レミー on 13/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import Intents
import Alamofire

class DeparturesIntentHandler: INExtension, DeparturesIntentHandling {
  func handle(intent: DeparturesIntent,
              completion: @escaping (DeparturesIntentResponse) -> Void) {
    guard let stopCode = intent.stop?.identifier else {
      completion(DeparturesIntentResponse(code: .failure, userActivity: nil))
      return
    }
    Alamofire
      .request(URL.departures(with: stopCode), method: .get)
      .responseData { (response) in
        if let data = response.result.value {
          var options = DeparturesOptions()
          options.networkStatus = .online
          let jsonDecoder = JSONDecoder()
          jsonDecoder.userInfo = [ DeparturesOptions.key: options ]
          do {
            let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
            completion(json.intentResponse)
            return
          } catch {
            completion(DeparturesIntentResponse(code: .failure, userActivity: nil))
          }
        } else {
          completion(DeparturesIntentResponse(code: .failure, userActivity: nil))
        }
    }
  }

  func confirm(intent: DeparturesIntent,
               completion: @escaping (DeparturesIntentResponse) -> Void) {
    completion(DeparturesIntentResponse(code: .success, userActivity: nil))
  }
}
