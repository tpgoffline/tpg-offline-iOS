//
//  SearchButtonTableViewCell.swift
//  tpg offline
//
//  Created by Remy on 09/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class SearchButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .white
    }
}
