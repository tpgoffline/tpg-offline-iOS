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
import SwiftyJSON
import FontAwesomeKit
import SCLAlertView
import ChameleonFramework

class RouteToStopViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var timeToGoLabel: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    var stop: Stop!
    var directionsRoute: MKRoute!

    override func viewDidLoad() {
        super.viewDidLoad()
		
        walkLabel.attributedText = FAKIonIcons.androidWalkIconWithSize(timeToGoLabel.bounds.height).attributedString()
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()
		
		if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
			map.tintColor = AppValues.primaryColor
		}
		else {
			map.tintColor = AppValues.textColor
		}
     
        timeToGoLabel.textColor = AppValues.textColor
        walkLabel.textColor = AppValues.textColor
    }
}

extension RouteToStopViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: directionsRoute.polyline)
        
        renderer.lineWidth = 4
		
		if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
			renderer.strokeColor = AppValues.primaryColor
		}
		else {
			renderer.strokeColor = AppValues.textColor
		}
		
        return renderer
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.stop.location.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .Walking

        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler {response, error in
            guard let route = response?.routes.first else { return }
            
            self.directionsRoute = route
            
            self.map.removeOverlays(mapView.overlays)
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(
                route.polyline.boundingMapRect,
                animated: true
            )
            var timeToGo = userLocation.location!.distanceFromLocation(self.stop.location) / 1000
            timeToGo /= 5
            self.timeToGoLabel.text = String(Int(route.expectedTravelTime / 60)) + " Minutes".localized()
        }
        self.timeToGoLabel.text = "Chargement en cours".localized()
        
    }
}