//
//  loadingCellTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 20/04/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class loadingCellTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
