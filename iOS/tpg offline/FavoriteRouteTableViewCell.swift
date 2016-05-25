//
//  FavoriteRouteTableViewCell.swift
//  tpg offline
//
//  Created by remy on 20/02/16.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class FavoriteRouteTableViewCell: UITableViewCell {
	
	@IBOutlet weak var iconView: UIView!
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var accessoryImage: UIImageView!
	
	@IBOutlet weak var departureLabel: UILabel!
	@IBOutlet weak var arrivalLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		
	}
	
}
