//
//  RoutesListTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class RoutesListTableViewCell: UITableViewCell {

    @IBOutlet weak var departureImageView: UIImageView!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var hourDepartureLabel: UILabel!

    @IBOutlet weak var arrivalImageView: UIImageView!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var hourArrivalLabel: UILabel!

    @IBOutlet weak var durationImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
