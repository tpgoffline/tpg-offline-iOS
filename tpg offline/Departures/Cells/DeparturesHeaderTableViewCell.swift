//
//  DeparturesHeaderTableViewCell.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 07/01/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit

class DeparturesHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
