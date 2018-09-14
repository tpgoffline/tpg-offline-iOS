//
//  RouteMapViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 04/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Mapbox

class RouteMapViewController: UIViewController {

  @IBOutlet weak var mapView: MGLMapView!

  var connection: RouteConnection?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let mapView = self.mapView else { return }

    mapView.delegate = self
    
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
    
    title = Text.map

    ColorModeManager.shared.addColorModeDelegate(self)

    guard let connection = self.connection else { return }

    var allPoints: [CLLocationCoordinate2D] = []
    for section in connection.sections ?? [] {
      var coordinates: [CLLocationCoordinate2D] = []

      for step in section.journey?.passList ?? [] {
        let annotation = MGLPointAnnotation()
        annotation.coordinate =
          CLLocationCoordinate2D(latitude: step.station.coordinate.x,
                                 longitude: step.station.coordinate.y)
        coordinates.append(annotation.coordinate)
        allPoints.append(annotation.coordinate)
        annotation.title = step.station.name.toStopName
        mapView.addAnnotation(annotation)
      }

      if !coordinates.isEmpty {
        let geodesic = MGLPolyline(coordinates: &coordinates,
                                   count: UInt(coordinates.count))
        geodesic.title = section.journey?.lineCode ?? ""
        mapView.add(geodesic)
      }
    }

    if allPoints.isEmpty {
      allPoints = [
        CLLocationCoordinate2D(latitude: connection.from.station.coordinate.x,
                               longitude: connection.from.station.coordinate.y),
        CLLocationCoordinate2D(latitude: connection.to.station.coordinate.x,
                               longitude: connection.to.station.coordinate.y)]
      let fromAnnotation = MGLPointAnnotation()
      fromAnnotation.title = connection.from.station.name.toStopName
      fromAnnotation.coordinate =
        CLLocationCoordinate2D(latitude: connection.from.station.coordinate.x,
                               longitude: connection.from.station.coordinate.y)
      mapView.addAnnotation(fromAnnotation)

      let toAnnotation = MGLPointAnnotation()
      toAnnotation.title = connection.to.station.name.toStopName
      toAnnotation.coordinate =
        CLLocationCoordinate2D(latitude: connection.to.station.coordinate.x,
                               longitude: connection.to.station.coordinate.y)
      mapView.addAnnotation(toAnnotation)

      let geodesic = MGLPolyline(coordinates: &allPoints,
                                 count: UInt(allPoints.count))
      geodesic.title = "Walk"
      mapView.add(geodesic)
    }

    mapView.setCenter(allPoints[0], zoomLevel: 14, animated: false)
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension RouteMapViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView,
               strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    if let annotation = annotation as? MGLPolyline {
      if (annotation.title ?? "") == "Walk" {
        return App.darkMode ? .white : .black
      } else {
        return LineColorManager.color(for: (annotation.title ?? ""))
      }
    } else {
      return App.darkMode ? .white : .black
    }
  }

  func mapView(_ mapView: MGLMapView,
               annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    if annotation is MGLPolyline {
      return false
    } else {
      return true
    }
  }
}
