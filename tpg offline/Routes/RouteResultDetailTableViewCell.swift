//
//  RouteResultDetailTableViewCell.swift
//  tpg offline
//
//  Created by Remy on 21/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class RouteResultDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var lineBackgroundView: UIView!
    @IBOutlet weak var departureStopLabel: UILabel!
    @IBOutlet weak var departureHourLabel: UILabel!
    @IBOutlet weak var arrivalStopLabel: UILabel!
    @IBOutlet weak var arrivalHourLabel: UILabel!

    @IBOutlet var images: [UIImageView]!

    var section: RouteConnection.Sections? = nil {
        didSet {
            guard let section = section else { return }

            let destinationName = App.stops.filter({$0.nameTransportAPI == section.journey?.to})[safe: 0]?.name
                ?? (section.journey?.to ?? "#?!")

            self.lineLabel.text = String(format: "Line %@ - %@".localized, "\(section.journey?.lineCode ?? "#?!".localized)", "\(destinationName)")
            if section.journey?.compagny == "TPG" {
                self.lineBackgroundView.backgroundColor = App.color(for: section.journey?.lineCode ?? "")
                self.lineLabel.textColor = App.color(for: section.journey?.lineCode ?? "").contrast
            } else if section.journey?.compagny == "SBB" {
                self.lineLabel.text = String(format: "SBB %@ - %@".localized, "\(section.journey?.lineCode ?? "#?!".localized)",
                    "\(destinationName)")
                self.lineBackgroundView.backgroundColor = .red
                self.lineLabel.textColor = .white
            } else {
                self.lineBackgroundView.backgroundColor = .black
                self.lineLabel.textColor = .white
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            departureStopLabel.text = (App.stops.filter({$0.sbbId == section.departure.station.id})[safe: 0]?.name)
                ?? section.departure.station.name
            departureHourLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(section.departure.departureTimestamp ?? 0)))
            arrivalStopLabel.text = (App.stops.filter({$0.sbbId == section.arrival.station.id})[safe: 0]?.name)
                ?? section.arrival.station.name
            arrivalHourLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(section.arrival.arrivalTimestamp ?? 0)))
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let view = UIView()
        view.backgroundColor = .clear
        self.selectedBackgroundView = view

        departureStopLabel.textColor = App.textColor
        departureHourLabel.textColor = App.textColor
        arrivalStopLabel.textColor = App.textColor
        arrivalHourLabel.textColor = App.textColor

        for image in images {
            image.image = image.image?.maskWith(color: App.textColor)
        }
    }
}
