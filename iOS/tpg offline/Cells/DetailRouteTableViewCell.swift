//
//  DetailRouteTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class DetailRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var hourDepartureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var hourArrivalLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
