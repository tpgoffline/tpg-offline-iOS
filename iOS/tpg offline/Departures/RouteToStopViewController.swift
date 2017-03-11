//
//  RouteToStopViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 13/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RouteToStopViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var timeToGoLabel: UILabel!
    @IBOutlet weak var walkImageView: UIImageView!
    var stop: Stop!
    var directionsRoute: MKRoute!

    override func viewDidLoad() {
        super.viewDidLoad()

        walkImageView.image = #imageLiteral(resourceName: "walking").maskWithColor(color: AppValues.textColor)

        let pin = MKPointAnnotation()
        pin.coordinate = self.stop.location.coordinate
        pin.title = self.stop.fullName

        map.addAnnotation(pin)

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: (self.stop.location.coordinate), span: span)
        map.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

		refreshTheme()
		if AppValues.primaryColor.contrast == .white {
			map.tintColor = AppValues.primaryColor
		} else {
			map.tintColor = AppValues.textColor
		}

        timeToGoLabel.textColor = AppValues.textColor
        walkImageView.tintColor = AppValues.textColor
    }
}

extension RouteToStopViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: directionsRoute.polyline)

        renderer.lineWidth = 4

		if AppValues.primaryColor.contrast == .white {
			renderer.strokeColor = AppValues.primaryColor
		} else {
			renderer.strokeColor = AppValues.textColor
		}

        return renderer
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.stop.location.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .walking

        let directions = MKDirections(request: request)

        directions.calculate {response, _ in
            guard let route = response?.routes.first else { return }

            self.directionsRoute = route

            self.map.removeOverlays(mapView.overlays)
            self.map.add(route.polyline)
            self.map.setVisibleMapRect(
                route.polyline.boundingMapRect,
                animated: true
            )
            var timeToGo = userLocation.location!.distance(from: self.stop.location) / 1000
            timeToGo /= 5
            self.timeToGoLabel.text = String(Int(route.expectedTravelTime / 60)) + " Minutes".localized
        }
        self.timeToGoLabel.text = "Chargement en cours".localized

    }
}
