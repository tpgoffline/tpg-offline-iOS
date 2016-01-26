//
//  SwitchTableViewCell.swift
//  tpg offline
//
//  Created by Alice on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import DGRunkeeperSwitch

class SwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var switchObject: DGRunkeeperSwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
