//
//  DepartsTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/11/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class DepartsTableViewCell: UITableViewCell {
    @IBOutlet weak var pictoLigne: UIImageView!
    @IBOutlet weak var labelDirection: UILabel!
    @IBOutlet weak var labelTempsRestant: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
