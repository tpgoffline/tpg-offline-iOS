//
//  Credit.swift
//  tpg offline
//
//  Created by Remy on 21/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import Foundation

struct Credit {
    var title: String = ""
    var subTitle: String = ""
    var action: ((Credit) -> Void)!
}
