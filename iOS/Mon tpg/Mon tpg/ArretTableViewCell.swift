//
//  ArretTableViewCell.swift
//  Mon tpg
//
//  Created by Alice on 16/08/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class ArretTableViewCell: UITableViewCell {
    @IBOutlet weak var imageLigne: UIImageView!
    @IBOutlet weak var labelDirection: UILabel!
    @IBOutlet weak var labeltempsProchainDepart: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
