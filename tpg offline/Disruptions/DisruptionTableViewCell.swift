//
//  DisruptionTableViewCell.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 18/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
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
      guard let disruption = disruption else {
        self.backgroundColor = App.cellBackgroundColor
        titleLabel.backgroundColor = .gray
        descriptionLabel.backgroundColor = .gray
        titleLabel.text = "   "
        descriptionLabel.text = "\n\n\n"
        titleLabel.cornerRadius = 10
        descriptionLabel.cornerRadius = 10
        titleLabel.clipsToBounds = true
        descriptionLabel.clipsToBounds = true
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(self.changeOpacity),
                                     userInfo: nil,
                                     repeats: true)
        return
      }
      self.color = App.color(for: disruption.line)

      titleLabel.alpha = 1
      descriptionLabel.alpha = 1

      titleLabel.backgroundColor = App.cellBackgroundColor
      descriptionLabel.backgroundColor = App.cellBackgroundColor
      titleLabel.textColor = color
      descriptionLabel.textColor = color

      titleLabel.cornerRadius = 0
      descriptionLabel.cornerRadius = 0

      titleLabel.text = disruption.nature
        .replacingOccurrences(of: "  ", with: " ")
        .replacingOccurrences(of: "' ", with: "'")
      if disruption.place != "" {
        let disruptionPlace = disruption.place
          .replacingOccurrences(of: "  ", with: " ")
          .replacingOccurrences(of: "' ", with: "'")
        titleLabel.text = titleLabel.text?.appending(" - \(disruptionPlace)")
      }
      self.backgroundColor = App.cellBackgroundColor
      descriptionLabel.text = disruption.consequence
        .replacingOccurrences(of: "  ", with: " ")
        .replacingOccurrences(of: "' ", with: "'")
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
    timer = Timer.scheduledTimer(timeInterval: 0.1,
                                 target: self,
                                 selector: #selector(self.changeOpacity),
                                 userInfo: nil,
                                 repeats: true)
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
