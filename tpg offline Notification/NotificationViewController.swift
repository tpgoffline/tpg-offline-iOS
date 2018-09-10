//
//  NotificationViewController.swift
//  tpg offline Notification
//
//  Created by Rémy Da Costa Faro on 14/07/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  @IBOutlet var mapView: MKMapView!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.mapView.delegate = self
  }

  func didReceive(_ notification: UNNotification) {
    guard let mapView = self.mapView else { return }
    mapView.removeAnnotations(mapView.annotations)
    let regionRadius: CLLocationDistance = 2000

    if notification.request.content.categoryIdentifier == "departureNotification",
      let x = notification.request.content.userInfo["x"] as? Double,
      let y = notification.request.content.userInfo["y"] as? Double,
      let stopName = notification.request.content.userInfo["stopName"] as? String {
      let coordinate = CLLocationCoordinate2D(latitude: x,
                                              longitude: y)
      let coordinateRegion = MKCoordinateRegion.init(center: coordinate,
                                                latitudinalMeters: regionRadius,
                                                longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)

      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = stopName
      mapView.addAnnotation(annotation)
    } else if
      notification.request.content.categoryIdentifier == "goNotification",
      let arrivalX = notification.request.content.userInfo["arrivalX"] as? Double,
      let arrivalY = notification.request.content.userInfo["arrivalY"] as? Double,
      let arrivalName =
      notification.request.content.userInfo["arrivalName"] as? String {
      if
        let departureX = notification.request.content.userInfo["departureX"]
          as? Double,
        let departureY = notification.request.content.userInfo["departureY"]
          as? Double,
        let departureName = notification.request.content.userInfo["departureName"]
          as? String {
        let arrivalCoordinates = CLLocationCoordinate2D(latitude: arrivalX,
                                                        longitude: arrivalY)
        let departureCoordinates = CLLocationCoordinate2D(latitude: departureX,
                                                          longitude: departureY)
        let arrivalPlacemark = MKPlacemark(coordinate: arrivalCoordinates,
                                           addressDictionary: nil)
        let departurePlacemark = MKPlacemark(coordinate: departureCoordinates,
                                             addressDictionary: nil)

        let arrivalMapItem = MKMapItem(placemark: arrivalPlacemark)
        let departureMapItem = MKMapItem(placemark: departurePlacemark)

        let arrivalAnnotation = MKPointAnnotation()
        arrivalAnnotation.coordinate = arrivalCoordinates
        arrivalAnnotation.title = arrivalName

        let departureAnnotation = MKPointAnnotation()
        departureAnnotation.coordinate = departureCoordinates
        departureAnnotation.title = departureName

        self.mapView.showAnnotations([arrivalAnnotation, departureAnnotation],
                                     animated: true )

        let directionRequest = MKDirections.Request()
        directionRequest.source = arrivalMapItem
        directionRequest.destination = departureMapItem
        directionRequest.transportType = .walking

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, _) -> Void in
          guard let response = response else {
            let coordinates = [arrivalCoordinates, departureCoordinates]
            let geodesic = MKPolyline(coordinates: coordinates,
                                      count: coordinates.count)
            mapView.addOverlay(geodesic)

            return
          }

          let route = response.routes[0]

          self.mapView.addOverlay(route.polyline,
                           level: MKOverlayLevel.aboveRoads)

          let rect = route.polyline.boundingMapRect
          self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
        }
      } else {
        let coordinate = CLLocationCoordinate2D(latitude: arrivalX,
                                                longitude: arrivalY)
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = arrivalName
        mapView.addAnnotation(annotation)
      }
    }
  }
}

extension NotificationViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView,
               rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer()
    }

    let polylineRenderer = MKPolylineRenderer(overlay: polyline)
    polylineRenderer.strokeColor = .black
    polylineRenderer.lineWidth = 2
    return polylineRenderer
  }
}
