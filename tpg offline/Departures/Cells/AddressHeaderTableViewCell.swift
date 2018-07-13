//
//  AddressHeaderTableViewCell.swift
//  tpg offline
//
//  Created by Rémy on 07/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import MapKit

class AddressHeaderTableViewCell: UITableViewCell {

  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!

  var search: GoogleMapsGeocodingSearch? {
    didSet {
      guard let search = search else {
        return
      }

      subtitleLabel.textColor = App.textColor
      addressLabel.textColor = App.textColor
      backgroundColor = App.cellBackgroundColor

      addressLabel.text = search.address

      guard let mapView = self.mapView else { return }
      mapView.removeAnnotations(mapView.annotations)

      let regionRadius: CLLocationDistance = 2000
      let coordinateRegion =
        MKCoordinateRegionMakeWithDistance(search.location.coordinate,
                                           regionRadius,
                                           regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)

      let annotation = MKPointAnnotation()
      annotation.coordinate = search.location.coordinate
      annotation.title = search.address
      mapView.addAnnotation(annotation)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    subtitleLabel.text = Text.nearestStopsFrom
    subtitleLabel.textColor = App.textColor
    addressLabel.text = ""
    addressLabel.textColor = App.textColor
    backgroundColor = App.cellBackgroundColor
  }
}
