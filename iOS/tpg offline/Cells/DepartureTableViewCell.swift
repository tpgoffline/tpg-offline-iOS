//
//  ExtendedDepartureTableViewCell.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 3/20/17.
//  Copyright © 2017 Rémy DA COSTA FARO. All rights reserved.
//

import UIKit

class DepartureTableViewCell: UITableViewCell {

    @IBOutlet var nextImages: [UIImageView]!

    @IBOutlet weak var buttonReminder: UIButton!
    @IBOutlet weak var buttonFollowTrack: UIButton!
    @IBOutlet weak var buttonSeeAllDepartures: UIButton!

    @IBOutlet weak var linePictogram: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
