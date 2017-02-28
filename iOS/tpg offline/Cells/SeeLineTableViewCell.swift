//
//  SeeLineTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 10/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class SeeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var connection1Label: UILabel!
    @IBOutlet weak var connection2Label: UILabel!
    @IBOutlet weak var connection3Label: UILabel!
    @IBOutlet weak var connection4Label: UILabel!
    @IBOutlet weak var barDirection: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func didMoveToSuperview() {
        layoutIfNeeded()
    }
}
