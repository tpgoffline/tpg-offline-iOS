//
//  DescriptionStopTableViewCell.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 3/19/17.
//  Copyright © 2017 Rémy DA COSTA FARO. All rights reserved.
//

import UIKit
import MapKit

class DescriptionStopTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!

    var coordinate: CLLocationCoordinate2D?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func centerMap() {
        guard let coordinate = self.coordinate else {
            return
        }
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        mapView.setRegion(region, animated: true)
    }
}
