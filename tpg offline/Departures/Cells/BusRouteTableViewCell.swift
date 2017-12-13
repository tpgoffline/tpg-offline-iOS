//
//  ThermometerTableViewCell.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 11/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

class BusRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var busTrackView: UIView!
    @IBOutlet weak var remainingTimeLabel: UILabel!

    var busRoute: BusRoute?

    func configure(with busRoute: BusRoute, color: UIColor, selected: Bool = false) {
        self.busRoute = busRoute
        var color = busRoute.arrivalTime != "" ? color : .gray
        self.backgroundColor = selected ? color : .white
        color = selected ? color.contrast : color

        titleLabel.textColor = color
        titleLabel.text = App.stops.filter({ $0.code == busRoute.stop.code })[safe: 0]?.name ?? "Unknow".localized

        remainingTimeLabel.textColor = color
        remainingTimeLabel.text = busRoute.arrivalTime == "" ? "" : "\(busRoute.arrivalTime)'"

        let accebilityLabel = busRoute.arrivalTime == "" ?
            String(format: "%@, stop already passed".localized, titleLabel.text ?? "") :
            String(format: "%@, departure in %@ minutes".localized, titleLabel.text ?? "")
        self.accessibilityLabel = accebilityLabel

        var rectanglePath: UIBezierPath

        if busRoute.first {
            rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5,
                                                      y: self.bounds.height / 2, width: 9, height: self.bounds.height))
        } else if busRoute.last {
            rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5, y: 0, width: 9, height: self.bounds.height / 2))
        } else {
            rectanglePath = UIBezierPath(rect: CGRect(x: self.bounds.height / 2 - 4.5, y: 0, width: 9, height: self.bounds.height))
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
        shapeLayer.lineWidth = 3

        self.busTrackView.layer.addSublayer(shapeLayer)

        shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = color.cgColor
        shapeLayer.lineWidth = 3

        self.busTrackView.layer.addSublayer(shapeLayer)
        self.busTrackView.backgroundColor = self.backgroundColor

        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = color.withAlphaComponent(0.1)
    }
}
