//
//  DeparturesTableViewCell.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 10/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit

class DeparturesTableViewCell: UITableViewCell {

  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var platformLabel: UILabel!
  @IBOutlet weak var rightTimeLabel: UILabel!
  @IBOutlet weak var rightImage: UIImageView!
  @IBOutlet weak var wifiImage: UIImageView!
  @IBOutlet weak var notPMRImage: UIImageView!

  var loading = true
  var timer: Timer?
  var opacity = 0.5

  var canBeSelected: Bool = true
  var departure: Departure? {
    didSet {
      guard let departure = self.departure else {
        destinationLabel.text = "---"
        rightTimeLabel.text = "--'"
        platformLabel.isHidden = true
        wifiImage.isHidden = true
        notPMRImage.isHidden = true
        destinationLabel.textColor = App.textColor
        rightTimeLabel.textColor = App.textColor
        accessoryType = .none
        isUserInteractionEnabled = false
        rightImage.image = nil
        wifiImage.image = nil
        canBeSelected = false
        loading = true
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(self.changeOpacity),
                                     userInfo: nil,
                                     repeats: true)
        return
      }
      guard let stop = self.stop else { return }
      self.loading = false

      destinationLabel.alpha = 1
      rightTimeLabel.alpha = 1

      var color = App.color(for: departure.line.code,
                            operator: stop.lines[departure.line.code] ?? .tpg)

      destinationLabel.text = App.replacementsNames[departure.line.destination] ??
        departure.line.destination
      destinationLabel.textColor = color

      notPMRImage.image = departure.reducedMobilityAccessibility == .accessible ?
        nil : #imageLiteral(resourceName: "notPMR").maskWith(color: color)
      notPMRImage.isHidden = departure.reducedMobilityAccessibility == .accessible

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
          rightTimeLabel.isHidden = false
          rightImage.image = nil
          rightImage.isHidden = true
          self.accessibilityLabel =
            Text.directionDeparture(to: destinationLabel.text,
                                    at: rightTimeLabel.text)
        } else {
          rightTimeLabel.text = ""
          rightTimeLabel.isHidden = true
          rightImage.image = #imageLiteral(resourceName: "warning").maskWith(color: color)
          rightImage.isHidden = false
          self.accessibilityLabel =
            Text.directionErrorLoading(to: destinationLabel.text)
        }
        canBeSelected = true
      case "no more":
        rightTimeLabel.text = ""
        rightTimeLabel.isHidden = true
        rightImage.image = #imageLiteral(resourceName: "cross").maskWith(color: .gray)
        rightImage.isHidden = false
        destinationLabel.textColor = .gray
        color = .gray
        canBeSelected = false
        self.accessibilityLabel = Text.directionNoMore(to: destinationLabel.text)
      case "0":
        rightTimeLabel.text = ""
        rightTimeLabel.isHidden = true
        rightImage.image = #imageLiteral(resourceName: "bus").maskWith(color: color)
        rightImage.isHidden = false
        canBeSelected = true
        self.accessibilityLabel = Text.directionLeaving(to: destinationLabel.text)
      default:
        let time = departure.leftTime.time
        rightTimeLabel.text =
        "\(departure.reliability == .theoretical ? "~" : "")\(time)'"
        rightTimeLabel.isHidden = false
        rightImage.image = nil
        rightImage.isHidden = true
        canBeSelected = true
        self.accessibilityLabel =
          Text.directionDeparture(to: destinationLabel.text,
                                  inMinutes: departure.leftTime.accessibleTime)
      }

      if stop.lines[departure.line.code] == .tac {
        canBeSelected = false
      }

      wifiImage.image = departure.wifi ? #imageLiteral(resourceName: "wifi").maskWith(color: color) : nil
      wifiImage.isHidden = !departure.wifi

      rightTimeLabel.textColor = color
      if canBeSelected {
        accessoryType = .disclosureIndicator
        isUserInteractionEnabled = true
      } else {
        accessoryType = .none
        isUserInteractionEnabled = false
      }

      if let platform = departure.platform {
        platformLabel.text = String(format: "Platform %@".localized, platform)
        platformLabel.textColor = color
        platformLabel.isHidden = false
      } else {
        platformLabel.isHidden = true
      }

      self.backgroundColor = App.cellBackgroundColor
      self.selectedBackgroundView = UIView()
      self.selectedBackgroundView?.backgroundColor = color.withAlphaComponent(0.1)
    }
  }

  var stop: Stop?

  override func awakeFromNib() {
    super.awakeFromNib()

    self.backgroundColor = App.cellBackgroundColor

    destinationLabel.text = "---"
    rightTimeLabel.text = "--'"
    timer = Timer.scheduledTimer(timeInterval: 0.1,
                                 target: self,
                                 selector: #selector(self.changeOpacity),
                                 userInfo: nil,
                                 repeats: true)
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
