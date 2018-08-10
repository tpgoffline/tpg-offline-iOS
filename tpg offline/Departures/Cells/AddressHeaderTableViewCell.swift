//
//  AddressHeaderTableViewCell.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 07/07/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Mapbox

class AddressHeaderTableViewCell: UITableViewCell {

  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: MGLMapView!

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
      if let annotations = mapView.annotations {
        mapView.removeAnnotations(annotations)
      }
      
      mapView.styleURL = URL.mapUrl
      mapView.reloadStyle(self)
      mapView.setCenter(search.location.coordinate, zoomLevel: 14, animated: false)

      let annotation = MGLPointAnnotation()
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
    
    guard let mapView = self.mapView else { return }
    if let annotations = mapView.annotations {
      mapView.removeAnnotations(annotations)
    }
    
    mapView.styleURL = URL.mapUrl
    mapView.showsUserLocation = true
  }
}
