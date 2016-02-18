//
//  ArretsImageTableViewCell.swift
//  tpg offline
//
//  Created by Alice on 01/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

class ArretsImageTableViewCell: UITableViewCell {
    @IBOutlet weak var labelLogo: UILabel!
    @IBOutlet weak var nomArret: UILabel!
    @IBOutlet weak var sousTitreArret: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
