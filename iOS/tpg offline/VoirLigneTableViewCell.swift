//
//  VoirLigneTableViewCell.swift
//  tpg offline
//
//  Created by Alice on 10/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class VoirLigneTableViewCell: UITableViewCell {

    @IBOutlet weak var tempsRestantLabel: UILabel!
    @IBOutlet weak var titreLabel: UILabel!
    @IBOutlet weak var sousTitreLabel: UILabel!
    @IBOutlet weak var correspondance1Label: UILabel!
    @IBOutlet weak var correspondance2Label: UILabel!
    @IBOutlet weak var correspondance3Label: UILabel!
    @IBOutlet weak var correspondance4Label: UILabel!
    @IBOutlet weak var barDirection: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
