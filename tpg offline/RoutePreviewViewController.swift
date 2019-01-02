//
//  RoutePreviewViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 13/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class RoutePreviewViewController: ScrollViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  
  var connection: [TimetablesManager.Connection] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.timeZone = Calendar.current.timeZone
    dateFormatter.dateStyle = .none
    
    for (index, x) in connection.enumerated() {
      if index == 0 || (connection[index - 1].line != x.line) {
        let routePreviewRow = RoutePreviewRow(frame: CGRect.zero)
        routePreviewRow.lineLabel.text = x.line
        routePreviewRow.lineLabel.textColor = LineColorManager.color(for: x.line).contrast
        routePreviewRow.lineBackgroundView.backgroundColor = LineColorManager.color(for: x.line)
        routePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathStart").colorize(with: LineColorManager.color(for: x.line))
        routePreviewRow.directionLabel.text = "Direction \(App.stops.first(where: { $0.sbbId == String(x.destinationStation) })?.name ?? "")"
        let date = Date(fromMidnight: x.departureSeconds)
        routePreviewRow.hourLabel.text = dateFormatter.string(from: date)
        routePreviewRow.stopNameLabel.text = App.stops.first(where: { $0.sbbId == String(x.departureStation) })?.name ?? ""
        self.stackView.addArrangedSubview(routePreviewRow)
      }
      
      let arrivalRoutePreviewRow = RoutePreviewRow(frame: CGRect.zero)
      arrivalRoutePreviewRow.lineBackgroundView.isHidden = true
      arrivalRoutePreviewRow.directionLabel.isHidden = true
      
      if index == connection.endIndex || connection[safe: index + 1]?.line != x.line {
        arrivalRoutePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathEnd").colorize(with: LineColorManager.color(for: x.line))
      } else {
        arrivalRoutePreviewRow.pathImageView.image = #imageLiteral(resourceName: "pathMiddle").colorize(with: LineColorManager.color(for: x.line))
      }
      
      let date = Date(fromMidnight: x.arrivalSeconds)
      arrivalRoutePreviewRow.hourLabel.text = dateFormatter.string(from: date)
      arrivalRoutePreviewRow.stopNameLabel.text = App.stops.first(where: { $0.sbbId == String(x.arrivalStation) })?.name ?? ""
      arrivalRoutePreviewRow.stopNameLabel.numberOfLines = 0
      
      self.stackView.addArrangedSubview(arrivalRoutePreviewRow)
    }
  }
}
