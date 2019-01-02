//
//  BusRouteViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 20/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit
import Alamofire

class BusRouteViewController: ScrollViewController {
  
  var loadingView: UIActivityIndicatorView!
  var departure: Departure!
  @IBOutlet weak var stackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadingView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .plain, target: self, action: #selector(reload), accessbilityLabel: "Reload"),
      UIBarButtonItem(customView: loadingView)
    ]
    self.reload()
  }
  
  @objc func reload() {
    self.loadingView.startAnimating()
    self.stackView.subviews.forEach({ $0.removeFromSuperview() })
    if departure.offline {
      let departures = TimetablesManager.shared.offlineDepartures(tripId: departure.vehiculeNo)
      let dateFormatter = DateFormatter()
      dateFormatter.timeStyle = .short
      dateFormatter.timeZone = Calendar.current.timeZone
      dateFormatter.dateStyle = .none
      
      for (index, x) in departures.enumerated() {
        let isPassed = (Int(x.leftTime) ?? 0) < 0
        let color = isPassed ? .gray : LineColorManager.color(for: x.line.code)
        
        if index == 0 {
          let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
          routePreviewRow.lineLabel.text = x.line.code
          routePreviewRow.lineLabel.textColor = color.contrast
          routePreviewRow.lineBackgroundView.backgroundColor = color
          routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathStart").colorize(with: color)
          routePreviewRow.directionLabel.text = "Direction \(departures.last?.line.destination ?? "")"
          routePreviewRow.hourLabel.text = isPassed ? "" : "\(x.leftTime)'"
          routePreviewRow.hourLabel.textColor = App.textColor
          routePreviewRow.stopNameLabel.text = App.stops.first(where: { $0.sbbId == String(x.stop!) })?.name ?? ""
          routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
          routePreviewRow.directionLabel.textColor = isPassed ? .gray : App.textColor
          self.stackView.addArrangedSubview(routePreviewRow)
        }
        
        let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
        routePreviewRow.lineBackgroundView.isHidden = true
        routePreviewRow.directionLabel.isHidden = true
        
        if index == departures.endIndex {
          routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathEnd").colorize(with: color)
        } else {
          routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathMiddle").colorize(with: color)
        }
        
        routePreviewRow.hourLabel.text = isPassed ? "" : "\(x.leftTime)'"
        routePreviewRow.hourLabel.textColor = App.textColor
        routePreviewRow.stopNameLabel.text = App.stops.first(where: { $0.sbbId == String(x.stop!) })?.name ?? ""
        routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
        routePreviewRow.stopNameLabel.numberOfLines = 0
        
        self.stackView.addArrangedSubview(routePreviewRow)
      }
      let stops = departures.compactMap { (departure) -> Stop? in
        App.stops.first(where: { (stop) -> Bool in
          stop.sbbId == "\(departure.stop ?? 0)"
        })
      }
      let centerTo = App.stops.first(where: { (stop) -> Bool in
        stop.appId == (departures.first(where: { $0.leftTime != "" }) ?? departures.last!).stop
      })?.location
      MapManager.shared.showPath(stops: stops, color: LineColorManager.color(for: departures.first?.line.code ?? ""), centerTo: centerTo)
      self.loadingView.stopAnimating()
    } else {
      Alamofire.request(URL.thermometer,
                        method: .get,
                        parameters: ["key": API.tpg,
                                     "departureCode": departure?.code ?? 0])
        .responseData { (response) in
          if let data = response.result.value {
            let jsonDecoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            let busRouteGroup = try? jsonDecoder.decode(BusRouteGroup.self, from: data)
            
            for (index, step) in (busRouteGroup?.steps ?? []).enumerated() {
              let isPassed = (step.arrivalTime == "")
              let color = isPassed ? .gray : LineColorManager.color(for: self.departure.line.code)
              
              if index == 0 {
                let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
                routePreviewRow.lineLabel.text = self.departure.line.code
                routePreviewRow.lineLabel.textColor = color.contrast
                routePreviewRow.lineBackgroundView.backgroundColor = color
                routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathStart").colorize(with: color)
                routePreviewRow.directionLabel.text = "Direction \((busRouteGroup?.steps ?? []).last?.stop.name ?? "")"
                routePreviewRow.hourLabel.text = isPassed ? "" : "\(step.arrivalTime)'"
                routePreviewRow.hourLabel.textColor = App.textColor
                routePreviewRow.stopNameLabel.text = step.stop.name
                routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
                routePreviewRow.directionLabel.textColor = isPassed ? .gray : App.textColor
                routePreviewRow.stopNameLabel.numberOfLines = 1
                routePreviewRow.directionLabel.numberOfLines = 1
                self.stackView.addArrangedSubview(routePreviewRow)
                continue
              }
              
              let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
              routePreviewRow.lineBackgroundView.isHidden = true
              routePreviewRow.directionLabel.isHidden = true
              
              if index == (busRouteGroup?.steps ?? []).endIndex - 1 {
                routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathEnd").colorize(with: color)
              } else {
                routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathMiddle").colorize(with: color)
              }
              
              routePreviewRow.hourLabel.text = isPassed ? "" : "\(step.arrivalTime)'"
              routePreviewRow.hourLabel.textColor = App.textColor
              routePreviewRow.stopNameLabel.text = step.stop.name
              routePreviewRow.stopNameLabel.textColor = isPassed ? .gray : App.textColor
              routePreviewRow.stopNameLabel.numberOfLines = 0
              
              self.stackView.addArrangedSubview(routePreviewRow)
            }
            self.loadingView.stopAnimating()
            
            let stops = (busRouteGroup?.steps ?? []).compactMap { (departure) -> Stop? in
              App.stops.first(where: { (stop) -> Bool in
                stop.code == departure.stop.code
              })
            }
            let centerTo = App.stops.first(where: { (stop) -> Bool in
              stop.code == (busRouteGroup?.steps.first(where: { $0.arrivalTime != "" }) ?? busRouteGroup?.steps.last)?.stop.code
            })?.location
            MapManager.shared.showPath(stops: stops, color: LineColorManager.color(for: self.departure.line.code), centerTo: centerTo)
          }
      }
    }
  }
}
