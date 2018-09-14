//
//  ThermometerTableViewCell.swift
//  tpgoffline
//
//  Created by Rémy Da Costa Faro on 11/06/2017.
//  Copyright © 2018 Rémy Da Costa Faro DA COSTA FARO. All rights reserved.
//

import UIKit

class BusRouteTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var busTrackView: UIImageView!
  @IBOutlet weak var remainingTimeLabel: UILabel!
  @IBOutlet weak var busImageView: UIImageView!

  var busRoute: BusRoute?
  var stop: Stop?

  func configure(with busRoute: BusRoute, color: UIColor, selected: Bool = false) {
    self.backgroundColor = App.darkMode ?
      App.cellBackgroundColor : (selected ? color : .white)
    self.busRoute = busRoute
    var color = busRoute.arrivalTime != "" ? color : .gray
    if !App.darkMode {
      color = selected ? color.contrast : color
    }

    titleLabel.textColor = color
    titleLabel.text = App.stops.filter({
      $0.code == busRoute.stop.code
    })[safe: 0]?.name ?? Text.unknow

    remainingTimeLabel.textColor = color

    if busRoute.arrivalTime == "00" {
      remainingTimeLabel.isHidden = true
      busImageView.image = #imageLiteral(resourceName: "bus").maskWith(color: color)
      busImageView.isHidden = false
    } else {
      remainingTimeLabel.text = busRoute.arrivalTime == "" ?"" :
        "\(busRoute.reliability == .theoretical ? "~" : "")\(busRoute.arrivalTime)'"
      remainingTimeLabel.isHidden = false
      busImageView.image = nil
      busImageView.isHidden = true
    }

    /*var rectanglePath: UIBezierPath

    if busRoute.first {
      rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                y: self.bounds.height / 2,
                                                width: 9,
                                                height: self.bounds.height))
    } else if busRoute.last {
      rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                y: 0,
                                                width: 9,
                                                height: self.bounds.height / 2))
    } else {
      rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                y: 0,
                                                width: 9,
                                                height: self.bounds.height))
    }

    let ovalPath = UIBezierPath(ovalIn: CGRect(x: self.bounds.height / 4,
                                               y: self.bounds.height / 4,
                                               width: self.bounds.height / 2,
                                               height: self.bounds.height / 2))

    color.setFill()
    rectanglePath.fill()
    ovalPath.fill()

    self.busTrackView.layer.sublayers?.removeAll()

    var shapeLayer = CAShapeLayer()
    shapeLayer.path = rectanglePath.cgPath
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.fillColor = color.cgColor
    shapeLayer.backgroundColor = App.cellBackgroundColor.cgColor
    shapeLayer.lineWidth = 3

    self.busTrackView.layer.addSublayer(shapeLayer)

    shapeLayer = CAShapeLayer()
    shapeLayer.path = ovalPath.cgPath
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.fillColor = color.cgColor
    shapeLayer.backgroundColor = App.cellBackgroundColor.cgColor
    shapeLayer.lineWidth = 3

    self.busTrackView.layer.addSublayer(shapeLayer)*/

    if busRoute.first {
      self.busTrackView.image = #imageLiteral(resourceName: "firstStep").maskWith(color: color)
    } else if busRoute.last {
      self.busTrackView.image = #imageLiteral(resourceName: "endStep").maskWith(color: color)
    } else {
      self.busTrackView.image = #imageLiteral(resourceName: "middleStep").maskWith(color: color)
    }

    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView?.backgroundColor = color.withAlphaComponent(0.1)

    self.accessoryType = .disclosureIndicator
  }

  func configure(with stopId: Int, color: UIColor, first: Bool, last: Bool) {
    self.backgroundColor = App.cellBackgroundColor
    guard let stop = App.stops.filter({ $0.appId == stopId })[safe: 0] else {
      print("Warning: \(stopId) was not found")
      titleLabel.text = "Unknow stop: \(stopId)"
      return
    }

    self.stop = stop

    var color = color

    if color.contrast == .black {
      color = color.darken(by: 0.1)
    }

    titleLabel.textColor = color
    titleLabel.text = stop.name

    remainingTimeLabel.text = ""

    //var rectanglePath: UIBezierPath

    if first {
      self.busTrackView.image = #imageLiteral(resourceName: "firstStep").maskWith(color: color)
    } else if last {
      self.busTrackView.image = #imageLiteral(resourceName: "endStep").maskWith(color: color)
    } else {
      self.busTrackView.image = #imageLiteral(resourceName: "middleStep").maskWith(color: color)
    }
    /*if first {
      rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                y: self.bounds.height / 2,
                                                width: 9,
                                                height: self.bounds.height))
    } else if last {
      rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                y: 0,
                                                width: 9,
                                                height: self.bounds.height / 2))
    } else {
      rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                y: 0,
                                                width: 9,
                                                height: self.bounds.height))
    }

    let ovalPath = UIBezierPath(ovalIn: CGRect(x: self.bounds.height / 4,
                                               y: self.bounds.height / 4,
                                               width: self.bounds.height / 2,
                                               height: self.bounds.height / 2))

    color.setFill()
    rectanglePath.fill()
    ovalPath.fill()

    self.busTrackView.layer.sublayers?.removeAll()

    var shapeLayer = CAShapeLayer()
    shapeLayer.path = rectanglePath.cgPath
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.fillColor = color.cgColor
    shapeLayer.backgroundColor = App.cellBackgroundColor.cgColor
    shapeLayer.lineWidth = 3

    self.busTrackView.layer.addSublayer(shapeLayer)

    shapeLayer = CAShapeLayer()
    shapeLayer.path = ovalPath.cgPath
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.fillColor = color.cgColor
    shapeLayer.backgroundColor = App.cellBackgroundColor.cgColor
    shapeLayer.lineWidth = 3

    self.busTrackView.layer.addSublayer(shapeLayer)
    self.busTrackView.backgroundColor = self.backgroundColor*/

    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView?.backgroundColor = color.withAlphaComponent(0.1)

    self.accessoryType = .disclosureIndicator
  }
}
