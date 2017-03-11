//
//  DeparturesTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class DeparturesTableViewCell: UITableViewCell {
    @IBOutlet weak var linePictogram: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
