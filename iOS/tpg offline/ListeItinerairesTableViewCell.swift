//
//  ListeItinerairesTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class ListeItinerairesTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDepart: UILabel!
    @IBOutlet weak var labelHeureDepart: UILabel!
    
    @IBOutlet weak var labelArrivee: UILabel!
    @IBOutlet weak var labelHeureArrivee: UILabel!
    
    @IBOutlet weak var labelDuree: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
