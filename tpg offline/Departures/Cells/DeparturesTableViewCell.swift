//
//  DeparturesTableViewCell.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 10/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

class DeparturesTableViewCell: UITableViewCell {

    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var rightImage: UIImageView!

    var loading = true
    var timer: Timer?
    var opacity = 0.5

    var canBeSelected: Bool = true
    var departure: Departure? {
        didSet {
            guard let departure = self.departure else { return }
            let color = App.color(for: departure.line.code)

            destinationLabel.text = App.replacementsNames[departure.line.destination] ?? departure.line.destination
            destinationLabel.textColor = color

            switch departure.leftTime {
            case "&gt;1h":
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                let time = dateFormatter.date(from: departure.timestamp)
                if let time = time {
                    rightTimeLabel.text = DateFormatter.localizedString(
                        from: time,
                        dateStyle: DateFormatter.Style.none,
                        timeStyle: DateFormatter.Style.short)
                    rightImage.image = nil
                    self.accessibilityLabel = String(format: "Direction %@, departure at %@".localized,
                    destinationLabel.text ?? "", rightTimeLabel.text ?? "")
                } else {
                    rightTimeLabel.text = ""
                    rightImage.image = #imageLiteral(resourceName: "warning").maskWith(color: color)
                    self.accessibilityLabel = String(format: "Direction %@, error while loading the remaining time".localized,
                                                     destinationLabel.text ?? "")
                }
                canBeSelected = true
            case "no more":
                rightTimeLabel.text = ""
                rightImage.image = #imageLiteral(resourceName: "cross").maskWith(color: .gray)
                destinationLabel.textColor = .gray
                canBeSelected = false
                self.accessibilityLabel = String(format: "Direction %@, no more bus".localized, destinationLabel.text ?? "")
            case "0":
                rightTimeLabel.text = ""
                rightImage.image = #imageLiteral(resourceName: "bus").maskWith(color: color)
                canBeSelected = true
                self.accessibilityLabel = String(format: "Direction %@, leaving now".localized, destinationLabel.text ?? "")
            default:
                rightTimeLabel.text = "\(departure.leftTime.time)'"
                rightImage.image = nil
                canBeSelected = true
                self.accessibilityLabel = String(format: "Direction %@, departure in %@ minutes".localized,
                                                 destinationLabel.text ?? "", "\(departure.leftTime.accessibleTime)")
            }

            rightTimeLabel.textColor = color
            if canBeSelected {
                accessoryType = .disclosureIndicator
                isUserInteractionEnabled = true
            } else {
                accessoryType = .none
                isUserInteractionEnabled = false
            }

            self.selectedBackgroundView = UIView()
            self.selectedBackgroundView?.backgroundColor = color.withAlphaComponent(0.1)
            self.loading = false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        destinationLabel.text = "---"
        rightTimeLabel.text = "--'"
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.changeOpacity), userInfo: nil, repeats: true)
    }

    @objc func changeOpacity() {
        if loading == false {
            timer?.invalidate()

            destinationLabel.alpha = 1
            rightTimeLabel.alpha = 1
        } else {
            self.opacity += 0.010
            if self.opacity >= 0.2 {
                self.opacity = 0.1
            }
            var opacity = CGFloat(self.opacity)
            if opacity > 0.5 {
                opacity -= (0.5 - opacity)
            }

            rightTimeLabel.alpha = opacity
            destinationLabel.alpha = opacity
        }
    }
}
