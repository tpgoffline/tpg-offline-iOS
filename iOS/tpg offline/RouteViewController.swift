//
//  RouteViewController.swift
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

class RouteViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelPieton: UILabel!
    var arret: Arret!
    var directionsRoute: MKRoute!
    override func viewDidLoad() {
        super.viewDidLoad()
		
        labelPieton.attributedText = FAKIonIcons.androidWalkIconWithSize(label.bounds.height).attributedString()
        
        let pin = MKPointAnnotation()
        pin.coordinate = self.arret.location.coordinate
        pin.title = self.arret.nomComplet
		
        map.addAnnotation(pin)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: (self.arret.location.coordinate), span: span)
        map.setRegion(region, animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        actualiserTheme()
		
		if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
			map.tintColor = AppValues.primaryColor
		}
		else {
			map.tintColor = AppValues.textColor
		}
     
        label.textColor = AppValues.textColor
        labelPieton.textColor = AppValues.textColor
    }
}

extension RouteViewController : MKMapViewDelegate {
    
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
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.arret.location.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .Walking

        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let route = response?.routes.first else { return }
            
            self.directionsRoute = route
            
            self.map.removeOverlays(mapView.overlays)
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(
                route.polyline.boundingMapRect,
                animated: true
            )
        }

        var temps = userLocation.location!.distanceFromLocation(self.arret.location) / 1000
        temps /= 5
        self.label.text = String(Int(temps * 100)) + " Minutes".localized()
    }
}