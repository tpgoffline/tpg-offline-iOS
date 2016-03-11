//
//  FavorisTableViewCell.swift
//  tpg offline
//
//  Created by remy on 20/02/16.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class FavorisItinerairesTableViewCell: UITableViewCell {
	
	@IBOutlet weak var iconeView: UIView!
	@IBOutlet weak var iconeImage: UIImageView!
	@IBOutlet weak var accessoryImage: UIImageView!
	
	@IBOutlet weak var labelDepart: UILabel!
	@IBOutlet weak var labelArrivee: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		
	}
	
}
