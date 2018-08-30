//
//  StopsTableViewself.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 29/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
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

    let titleAttributes: [NSAttributedString.Key: Any]
    let subtitleAttributes: [NSAttributedString.Key: Any]

    let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
    let subheadlineFont = UIFont.preferredFont(forTextStyle: .subheadline)

    if stop.subTitle != "", !isNearestStops {
      titleAttributes = [NSAttributedString.Key.font: subheadlineFont,
                         NSAttributedString.Key.foregroundColor: App.textColor]
        as [NSAttributedString.Key: Any]
      subtitleAttributes = [NSAttributedString.Key.font: headlineFont,
                            NSAttributedString.Key.foregroundColor: App.textColor]
        as [NSAttributedString.Key: Any]
    } else {
      titleAttributes = [NSAttributedString.Key.font: headlineFont,
                         NSAttributedString.Key.foregroundColor: App.textColor]
        as [NSAttributedString.Key: Any]
      subtitleAttributes = [NSAttributedString.Key.font: subheadlineFont,
                            NSAttributedString.Key.foregroundColor: App.textColor]
        as [NSAttributedString.Key: Any]
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
