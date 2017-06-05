//
//  SettingsTableViewCell.swift
//  tpg offline
//
//  Created by Remy DA COSTA FARO on 27/05/2017.
//  Copyright © 2017 Rémy DA COSTA FARO. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
