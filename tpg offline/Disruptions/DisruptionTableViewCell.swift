//
//  DisruptionTableViewCell.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 18/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

class DisruptionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var color: UIColor = .white
    var loading = true
    var timer: Timer?
    var opacity = 0.5

    var disruption: Disruption? = nil {
        didSet {
            guard let disruption = disruption else { return }
            self.color = App.color(for: disruption.line)

            titleLabel.backgroundColor = App.cellBackgroundColor
            descriptionLabel.backgroundColor = App.cellBackgroundColor
            titleLabel.textColor = color
            descriptionLabel.textColor = color

            titleLabel.cornerRadius = 0
            descriptionLabel.cornerRadius = 0

            titleLabel.text = disruption.nature
            if disruption.place != "" {
                titleLabel.text = titleLabel.text?.appending(" - \(disruption.place)")
            }
            descriptionLabel.text = disruption.consequence
            self.loading = false
        }
    }

    var devDisruption: DevDisruption? = nil {
        didSet {
            guard let devDisruption = devDisruption else { return }

            titleLabel.backgroundColor = App.cellBackgroundColor
            descriptionLabel.backgroundColor = App.cellBackgroundColor
            titleLabel.textColor = App.textColor
            descriptionLabel.textColor = App.textColor

            titleLabel.cornerRadius = 0
            descriptionLabel.cornerRadius = 0

            titleLabel.text = devDisruption.title
            descriptionLabel.text = devDisruption.text
            self.loading = false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = App.cellBackgroundColor
        titleLabel.backgroundColor = .gray
        descriptionLabel.backgroundColor = .gray
        titleLabel.text = "   "
        descriptionLabel.text = "\n\n\n"
        titleLabel.cornerRadius = 10
        descriptionLabel.cornerRadius = 10
        titleLabel.clipsToBounds = true
        descriptionLabel.clipsToBounds = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.changeOpacity), userInfo: nil, repeats: true)
    }

    @objc func changeOpacity() {
        if loading == false {
            timer?.invalidate()
            titleLabel.alpha = 1
            descriptionLabel.alpha = 1
        } else {
            self.opacity += 0.010
            if self.opacity >= 0.2 {
                self.opacity = 0.1
            }
            var opacity = CGFloat(self.opacity)
            if opacity > 0.5 {
                opacity -= (0.5 - opacity)
            }
            titleLabel.alpha = opacity
            descriptionLabel.alpha = opacity
        }
    }
}

class DisruptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lineLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = true
    }
}
