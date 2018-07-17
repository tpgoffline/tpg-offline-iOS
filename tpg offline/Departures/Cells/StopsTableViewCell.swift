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
    self.accessoryType = .disclosureIndicator
    self.backgroundColor = .white

    if App.darkMode {
      self.backgroundColor = App.cellBackgroundColor
      let selectedView = UIView()
      selectedView.backgroundColor = .black
      self.selectedBackgroundView = selectedView
    } else {
      self.backgroundColor = App.cellBackgroundColor
      let selectedView = UIView()
      selectedView.backgroundColor = UIColor.white.darken(by: 0.1)
      self.selectedBackgroundView = selectedView
    }

    let titleAttributes: [NSAttributedStringKey: Any]
    let subtitleAttributes: [NSAttributedStringKey: Any]

    let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
    let subheadlineFont = UIFont.preferredFont(forTextStyle: .subheadline)

    if stop.subTitle != "", !isNearestStops {
      titleAttributes = [NSAttributedStringKey.font: subheadlineFont,
                         NSAttributedStringKey.foregroundColor: App.textColor]
        as [NSAttributedStringKey: Any]
      subtitleAttributes = [NSAttributedStringKey.font: headlineFont,
                            NSAttributedStringKey.foregroundColor: App.textColor]
        as [NSAttributedStringKey: Any]
    } else {
      titleAttributes = [NSAttributedStringKey.font: headlineFont,
                         NSAttributedStringKey.foregroundColor: App.textColor]
        as [NSAttributedStringKey: Any]
      subtitleAttributes = [NSAttributedStringKey.font: subheadlineFont,
                            NSAttributedStringKey.foregroundColor: App.textColor]
        as [NSAttributedStringKey: Any]
    }
    self.textLabel?.numberOfLines = 0
    self.detailTextLabel?.numberOfLines = 0

    self.textLabel?.attributedText =
      NSAttributedString(string: stop.title,
                         attributes: titleAttributes)
    self.detailTextLabel?.attributedText =
      NSAttributedString(string: stop.subTitle,
                         attributes: subtitleAttributes)

    if isNearestStops {
      self.textLabel?.attributedText =
        NSAttributedString(string: stop.name,
                           attributes: titleAttributes)
      let walkDuration = Int(stop.distance / 1000 / 5 * 60)
      let walkDurationString = Text.distance(meters: stop.distance,
                                           minutes: walkDuration)

      self.detailTextLabel?.attributedText =
        NSAttributedString(string: walkDurationString,
                           attributes: subtitleAttributes)
      self.detailTextLabel?.accessibilityLabel = walkDuration == 0 ?
        String(format: "%@m".localized, "\(Int(stop.distance))"):
        String(format: "%@ meters, about %@ minutes to walk".localized,
               "\(Int(stop.distance))",
               "\(walkDuration)")
    }
  }
}
