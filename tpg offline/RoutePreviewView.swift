//
//  RoutePreviewView.swift
//  TEI
//
//  Created by Rémy on 11/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class RoutePreviewView: UIView {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if !connection.isEmpty {
      drawPattern()
    }
  }
  
  var connection: [TimetablesManager.Connection] = [] {
    didSet {
      drawPattern()
    }
  }
  
  func drawPattern() {
//    sublayer.forEach({ $0.removeFromSuperview() })
    layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    let departureSeconds = connection.first?.departureSeconds ?? 0
    let arrivalTime = (connection.last?.arrivalSeconds ?? 0) - departureSeconds
    
    for x in connection  {
      //// Rectangle Drawing
//      let width = (CGFloat(x.arrivalSeconds - departureSeconds) / CGFloat(arrivalTime) * self.bounds.width) - (CGFloat(x.departureSeconds - departureSeconds) / CGFloat(arrivalTime) * self.bounds.width) - 12
//      let rectanglePath = UIBezierPath(rect: CGRect(x: (CGFloat(x.departureSeconds - departureSeconds) / CGFloat(arrivalTime) * self.bounds.width), y: 4, width: width, height: 4))
//
//      var shapeLayer = CAShapeLayer()
//      shapeLayer.path = rectanglePath.cgPath
//
//      shapeLayer.fillColor = LineColorManager.color(for: x.line).cgColor
//      shapeLayer.strokeColor = LineColorManager.color(for: x.line).cgColor
//      shapeLayer.lineWidth = 3.0
//      shapeLayer.backgroundColor = UIColor.clear.cgColor
//
//      self.layer.addSublayer(shapeLayer)
      
      //// Oval Drawing
      var ovalPath = UIBezierPath(ovalIn: CGRect(x: CGFloat(x.departureSeconds - departureSeconds) / CGFloat(arrivalTime) * self.bounds.width, y: 0, width: 12, height: 12))
      var shapeLayer = CAShapeLayer()
      shapeLayer.path = ovalPath.cgPath
      
      shapeLayer.fillColor = LineColorManager.color(for: x.line).cgColor
      shapeLayer.strokeColor = LineColorManager.color(for: x.line).cgColor
      shapeLayer.lineWidth = 3.0
      shapeLayer.backgroundColor = UIColor.clear.cgColor
      
      self.layer.addSublayer(shapeLayer)
      
      //// Oval Drawing
      ovalPath = UIBezierPath(ovalIn: CGRect(x: CGFloat(x.arrivalSeconds - departureSeconds) / CGFloat(arrivalTime) * self.bounds.width, y: 0, width: 12, height: 12))
      
      shapeLayer = CAShapeLayer()
      shapeLayer.path = ovalPath.cgPath
      
      shapeLayer.fillColor = LineColorManager.color(for: x.line).cgColor
      shapeLayer.strokeColor = LineColorManager.color(for: x.line).cgColor
      shapeLayer.lineWidth = 3.0
      shapeLayer.backgroundColor = UIColor.clear.cgColor
      
      self.layer.addSublayer(shapeLayer)
    }
  }
}
