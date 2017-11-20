//
//  AllDeparturesCollectionViewCell.swift
//  tpg offline
//
//  Created by Remy on 01/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class AllDeparturesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!

    var loading = true
    var timer: Timer?
    var opacity = 0.5

    var departure: Departure? {
        didSet {
            guard let departure = departure else { return }
            guard let date = departure.dateCompenents?.date else {
                self.label.text = "#?!".localized
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            self.label.text = dateFormatter.string(from: date)
            self.loading = false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        label.text = "--:--"
        label.textColor = App.textColor
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.changeOpacity), userInfo: nil, repeats: true)
    }

    @objc func changeOpacity() {
        if loading == false {
            timer?.invalidate()

            label.alpha = 1
        } else {
            self.opacity += 0.010
            if self.opacity >= 0.2 {
                self.opacity = 0.1
            }
            var opacity = CGFloat(self.opacity)
            if opacity > 0.5 {
                opacity -= (0.5 - opacity)
            }

            label.alpha = opacity
        }
    }
}
