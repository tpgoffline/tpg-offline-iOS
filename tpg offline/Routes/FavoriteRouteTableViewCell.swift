//
//  FavoriteRouteTableViewCell.swift
//  tpg offline
//
//  Created by Remy on 24/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class FavoriteRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!

    @IBOutlet var images: [UIImageView]!

    var route: Route? = nil {
        didSet {
            guard let route = route else { return }
            fromLabel.text = route.from?.name ?? ""
            toLabel.text = route.to?.name ?? ""
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        fromLabel.textColor = App.textColor
        toLabel.textColor = App.textColor

        for image in images {
            image.image = image.image?.maskWith(color: App.textColor)
        }
    }
}
