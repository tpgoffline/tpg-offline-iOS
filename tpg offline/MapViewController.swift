//
//  MapViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 07/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController, MapDelegate {
  @IBOutlet weak var mapView: MGLMapView!
  @IBOutlet weak var blurEffect: UIVisualEffectView!
  
  var lineColor: UIColor = .black
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ColorModeManager.shared.add(self)
    blurEffect.effect = UIBlurEffect(style: App.darkMode ? .dark : .light)
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
    mapView.delegate = self
    MapManager.shared.add(self)
  }
  
  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    
    mapView.styleURL = URL.mapUrl
    mapView.reloadStyle(self)
  }
  
  deinit {
    ColorModeManager.shared.remove(self)
  }
  
  func centerTo(location: CLLocation, reloadStops: Bool) {
    if reloadStops {
      showAllStops()
    }
    mapView.setCenter(location.coordinate, animated: true)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
      // This is executed in a second time, due to a bug in Mapbox
      self.mapView.setCenter(location.coordinate, animated: true)
    }
    guard let annotations = mapView.annotations else { return }
    guard let annotation = annotations.first(where: { $0.coordinate == location.coordinate }) else { return }
    mapView.selectAnnotation(annotation, animated: true)
  }
  
  func showAllStops() {
    mapView.removeAnnotations(mapView.annotations ?? [])
    var annotations: [MGLAnnotation] = []
    for stop in App.stops {
      let annotation = MGLPointAnnotation()
      annotation.coordinate = stop.location.coordinate
      annotation.title = stop.title
      annotation.subtitle = stop.subTitle
      annotations.append(annotation)
    }
    mapView.addAnnotations(annotations)
  }
  
  func showPath(stops: [Stop], color: UIColor, centerTo location: CLLocation?) {
    self.lineColor = color
    mapView.removeAnnotations(mapView.annotations ?? [])
    var annotations: [MGLAnnotation] = []
    for stop in stops {
      let annotation = MGLPointAnnotation()
      annotation.coordinate = stop.location.coordinate
      annotation.title = stop.title
      annotation.subtitle = stop.subTitle
      annotations.append(annotation)
    }
    mapView.addAnnotations(annotations)
    let coordinates = stops.map({ $0.location.coordinate })
    let polyline = MGLPolyline(coordinates: coordinates,
                               count: UInt(coordinates.count))
    mapView.addAnnotation(polyline)
    if let location = location {
      centerTo(location: location, reloadStops: false)
    }
  }
}

extension MapViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView,
               annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    if annotation is MGLPolyline {
      return false
    } else {
      return true
    }
  }
  
  func mapView(_ mapView: MGLMapView,
               calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
    // Instantiate and return our custom callout view.
    return CustomCalloutView(representedObject: annotation)
  }
  
  func mapView(_ mapView: MGLMapView,
               strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    return self.lineColor
  }
}

class MapManager: NSObject {
  
  static let shared = MapManager()
  
  private var mapDelegates = [MapDelegate]()
  
  func add<T>(_ delegate: T) where
    T: MapDelegate, T: Equatable {
      mapDelegates.append(delegate)
  }
  
  func remove<T>(_ delegate: T) where
    T: MapDelegate, T: Equatable {
      for (index, mapDelegate) in mapDelegates.enumerated() {
        if let mapDelegate = mapDelegate as? T,
          mapDelegate == delegate {
          mapDelegates.remove(at: index)
          break
        }
      }
  }
  
  func centerTo(location: CLLocation, reloadStops: Bool = true) {
    DispatchQueue.main.async {
      self.mapDelegates.forEach({ $0.centerTo(location: location, reloadStops: reloadStops) })
    }
  }
  
  func showAllStops() {
    DispatchQueue.main.async {
      self.mapDelegates.forEach({ $0.showAllStops() })
    }
  }
  
  func showPath(stops: [Stop], color: UIColor, centerTo location: CLLocation?) {
    DispatchQueue.main.async {
      self.mapDelegates.forEach({ $0.showPath(stops: stops, color: color, centerTo: location) })
    }
  }
}

protocol MapDelegate: class {
  func centerTo(location: CLLocation, reloadStops: Bool)
  func showAllStops()
  func showPath(stops: [Stop], color: UIColor, centerTo location: CLLocation?)
}
