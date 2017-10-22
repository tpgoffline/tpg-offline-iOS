//
//  StopsTableViewself.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 29/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

class StopsTableViewCell: UITableViewCell {
    var stop: Stop?
    var isFavorite: Bool = false
    var isNearestStops: Bool = false

    func configure(with stop: Stop) {
        self.stop = stop
        self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWith(color: .gray))
        self.backgroundColor = .white

        let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                               NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        let subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline),
                                  NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        self.textLabel?.numberOfLines = 0
        self.detailTextLabel?.numberOfLines = 0

        self.textLabel?.attributedText = NSAttributedString(string: stop.title, attributes: titleAttributes)
        self.detailTextLabel?.attributedText = NSAttributedString(string: stop.subTitle, attributes: subtitleAttributes)

        if isNearestStops {
            self.textLabel?.attributedText = NSAttributedString(string: stop.name, attributes: titleAttributes)
            let walkDuration = Int(stop.distance / 1000 / 5 * 60)
            let walkDurationString = walkDuration == 0 ? String(format: "%@m".localized, "\(Int(stop.distance))"):
                String(format: "%@m (~%@ minutes)".localized, "\(Int(stop.distance))", "\(walkDuration)")
            self.detailTextLabel?.attributedText = NSAttributedString(string: walkDurationString, attributes: subtitleAttributes)
        }
    }
}
