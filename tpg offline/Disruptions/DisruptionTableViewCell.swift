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
  @IBOutlet weak var linesCollectionView: UICollectionView!
  @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

  var color: UIColor = .white
  var loading = true
  var timer: Timer?
  var opacity = 0.5

  var disruption: Disruption? = nil {
    didSet {
      guard let disruption = disruption else {
        self.backgroundColor = App.cellBackgroundColor
        self.linesCollectionView.backgroundColor = App.cellBackgroundColor
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
      self.linesCollectionView.backgroundColor = App.cellBackgroundColor

      titleLabel.alpha = 1
      descriptionLabel.alpha = 1

      titleLabel.backgroundColor = App.cellBackgroundColor
      descriptionLabel.backgroundColor = App.cellBackgroundColor
      titleLabel.textColor = App.textColor
      descriptionLabel.textColor = App.textColor

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
    self.linesCollectionView.backgroundColor = App.cellBackgroundColor
    lines = []
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
    linesCollectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    self.linesCollectionView.reloadData()
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let observedObject = object as? UICollectionView, observedObject == linesCollectionView {
      self.collectionViewHeight.constant = self.linesCollectionView.contentSize.height
    }
  }
  
  deinit {
    linesCollectionView.removeObserver(self, forKeyPath: "contentSize")
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
  
  var lines: [String] = [] {
    didSet {
      self.linesCollectionView.reloadData()
    }
  }
}

extension DisruptionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return lines.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = linesCollectionView.dequeueReusableCell(withReuseIdentifier: "disruptionLineCollectionViewCell", for: indexPath) as? DisruptionLineCollectionViewCell
      else { return UICollectionViewCell() }
    cell.label.text = lines[indexPath.row]
    let color = lines[indexPath.row] == "tpg" ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : App.color(for: lines[indexPath.row])
    cell.backgroundColor = App.darkMode ? UIColor.black.lighten(by: 0.1) : color
    cell.label.textColor = App.darkMode ? color : color.contrast
    cell.clipsToBounds = true
    cell.cornerRadius = cell.bounds.height / 2
    return cell
  }
}

class DisruptionLineCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var label: UILabel!
}
