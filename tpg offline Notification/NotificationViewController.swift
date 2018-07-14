//
//  NotificationViewController.swift
//  tpg offline Notification
//
//  Created by レミー on 14/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  @IBOutlet var mapView: MKMapView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func didReceive(_ notification: UNNotification) {
    if notification.request.content.categoryIdentifier == "departureNotification",
      let x = notification.request.content.userInfo["x"] as? Double,
      let y = notification.request.content.userInfo["y"] as? Double,
      let stopName = notification.request.content.userInfo["stopName"] as? String {
      guard let mapView = self.mapView else { return }
      mapView.removeAnnotations(mapView.annotations)

      let regionRadius: CLLocationDistance = 2000
      let coordinate = CLLocationCoordinate2D(latitude: x,
                                              longitude: y)
      let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                                latitudinalMeters: regionRadius,
                                                longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)

      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = stopName
      mapView.addAnnotation(annotation)
    }
  }

}
