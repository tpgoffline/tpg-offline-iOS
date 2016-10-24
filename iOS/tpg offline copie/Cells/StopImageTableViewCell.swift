//
//  StopImageTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 01/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class StopImageTableViewCell: UITableViewCell {
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stopSubTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
