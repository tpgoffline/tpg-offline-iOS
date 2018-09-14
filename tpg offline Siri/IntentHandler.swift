//
//  IntentHandler.swift
//  tpg offline Siri
//
//  Created by レミー on 13/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
      guard intent is DeparturesIntent else {
        fatalError("Unhandled intent type: \(intent)")
      }
      return DeparturesIntentHandler()
    }

}
