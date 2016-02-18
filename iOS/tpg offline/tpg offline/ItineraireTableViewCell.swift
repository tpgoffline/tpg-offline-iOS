//
//  ItineraireTableViewCell.swift
//  tpg offline
//
//  Created by Alice on 17/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class ItineraireTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var iconeImageView: UIImageView!
    @IBOutlet weak var ligneLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var heureDepartLabel: UILabel!
    @IBOutlet weak var arriveeLabel: UILabel!
    @IBOutlet weak var heureArriveeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
