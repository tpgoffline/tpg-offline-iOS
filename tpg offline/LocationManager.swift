//
//  LocationManager.swift
//  tpg offline beta
//
//  Created by Rémy on 11/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import Foundation
import CoreLocation
import Solar

class LocationManager: NSObject, CLLocationManagerDelegate {
  
  let locationManager = CLLocationManager()
  private var location: CLLocation? = nil
  
  open var nearestStops: [Stop] {
    guard let location = self.location else {
      return []
    }
    var localizedStops: [Stop] = []
    for stop in App.stops {
      let stopA = stop
      stopA.distance = location.distance(from: stopA.location)
      localizedStops.append(stopA)
    }
    localizedStops.sort(by: { $0.distance < $1.distance })
    return Array(localizedStops.prefix(5)).filter({ $0.distance < 1500 })
  }
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  @objc func checkTime() {
    if App.automaticDarkMode,
      App.sunriseSunsetManager?.isDaytime ?? false,
      App.darkMode == true {
      App.darkMode = false
    } else if App.automaticDarkMode,
      App.sunriseSunsetManager?.isNighttime ?? false,
      App.darkMode == false {
      App.darkMode = true
    }
  }
  
  static let shared = LocationManager()
  
  private var locationDelegates = [LocationDelegate]()
  
  func add<T>(_ delegate: T) where
    T: LocationDelegate, T: Equatable {
      locationDelegates.append(delegate)
  }
  
  func remove<T>(_ delegate: T) where
    T: LocationDelegate, T: Equatable {
      for (index, locationDelegate) in locationDelegates.enumerated() {
        if let locationDelegate = locationDelegate as? T,
          locationDelegate == delegate {
          locationDelegates.remove(at: index)
          break
        }
      }
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    if let location = locations[safe: 0] {
      App.sunriseSunsetManager = Solar(coordinate: location.coordinate)
      let nearestStop = self.nearestStops.first?.appId
      self.location = location
      if nearestStop != self.nearestStops.first?.appId {
        self.updateNearestStop()
      }
    } else {
      self.location = nil
    }
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didFailWithError error: Error) {
    location = nil
  }
  
  func updateNearestStop() {
    DispatchQueue.main.async {
      self.locationDelegates.forEach({ $0.nearestStopChanged() })
    }
  }
}

protocol LocationDelegate: class {
  func nearestStopChanged()
}
