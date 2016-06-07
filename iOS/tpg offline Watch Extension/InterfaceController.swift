//
//  InterfaceController.swift
//  tpg offline Watch Extension
//
//  Created by Alice on 05/06/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    let session = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
