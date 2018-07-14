//
//  LineColor.swift
//  tpg offline
//
//  Created by レミー on 13/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit

struct LineColorManager {
  private static var tpgLinesColor: [LineColor] =
    [LineColor(line: "1", color: UIColor(hexString: "5a1e82")!),
     LineColor(line: "2", color: UIColor(hexString: "cccc33")!),
     LineColor(line: "3", color: UIColor(hexString: "CC3399")!),
     LineColor(line: "4", color: UIColor(hexString: "CC0033")!),
     LineColor(line: "5", color: UIColor(hexString: "0099FF")!),
     LineColor(line: "6", color: UIColor(hexString: "0099CC")!),
     LineColor(line: "7", color: UIColor(hexString: "009933")!),
     LineColor(line: "8", color: UIColor(hexString: "993333")!),
     LineColor(line: "9", color: UIColor(hexString: "CC0033")!),
     LineColor(line: "10", color: UIColor(hexString: "32781e")!),
     LineColor(line: "11", color: UIColor(hexString: "993399")!),
     LineColor(line: "12", color: UIColor(hexString: "ff9900")!),
     LineColor(line: "14", color: UIColor(hexString: "5a1e82")!),
     LineColor(line: "15", color: UIColor(hexString: "993333")!),
     LineColor(line: "18", color: UIColor(hexString: "cc3399")!),
     LineColor(line: "19", color: UIColor(hexString: "ffcc00")!),
     LineColor(line: "21", color: UIColor(hexString: "663333")!),
     LineColor(line: "22", color: UIColor(hexString: "5a1e82")!),
     LineColor(line: "23", color: UIColor(hexString: "CC3399")!),
     LineColor(line: "25", color: UIColor(hexString: "993333")!),
     LineColor(line: "28", color: UIColor(hexString: "FFCC00")!),
     LineColor(line: "31", color: UIColor(hexString: "009999")!),
     LineColor(line: "32", color: UIColor(hexString: "666666")!),
     LineColor(line: "33", color: UIColor(hexString: "009999")!),
     LineColor(line: "34", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "35", color: UIColor(hexString: "666666")!),
     LineColor(line: "36", color: UIColor(hexString: "666666")!),
     LineColor(line: "41", color: UIColor(hexString: "009999")!),
     LineColor(line: "42", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "43", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "44", color: UIColor(hexString: "009999")!),
     LineColor(line: "45", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "46", color: UIColor(hexString: "009999")!),
     LineColor(line: "47", color: UIColor(hexString: "00B0A4")!),
     LineColor(line: "51", color: UIColor(hexString: "009999")!),
     LineColor(line: "53", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "54", color: UIColor(hexString: "009999")!),
     LineColor(line: "56", color: UIColor(hexString: "009999")!),
     LineColor(line: "57", color: UIColor(hexString: "99CCCC")!),
     LineColor(line: "61", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "A", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "B", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "C", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "D", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "DN", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "E", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "F", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "G", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "J", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "K", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "L", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "M", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "N", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "NA", color: UIColor(hexString: "5A1E82")!),
     LineColor(line: "NC", color: UIColor(hexString: "663399")!),
     LineColor(line: "ND", color: UIColor(hexString: "993333")!),
     LineColor(line: "NE", color: UIColor(hexString: "cc3399")!),
     LineColor(line: "NJ", color: UIColor(hexString: "cccc33")!),
     LineColor(line: "NK", color: UIColor(hexString: "ff9900")!),
     LineColor(line: "NM", color: UIColor(hexString: "ff9900")!),
     LineColor(line: "NO", color: UIColor(hexString: "B82F89")!),
     LineColor(line: "NP", color: UIColor(hexString: "009999")!),
     LineColor(line: "NS", color: UIColor(hexString: "008CBE")!),
     LineColor(line: "NT", color: UIColor(hexString: "00ACE7")!),
     LineColor(line: "NV", color: UIColor(hexString: "00ACE7")!),
     LineColor(line: "O", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "P", color: UIColor(hexString: "003399")!),
     LineColor(line: "S", color: UIColor(hexString: "003399")!),
     LineColor(line: "T", color: UIColor(hexString: "FF9BAA")!),
     LineColor(line: "TO", color: UIColor(hexString: "E2001D")!),
     LineColor(line: "TT", color: UIColor(hexString: "FD0000")!),
     LineColor(line: "U", color: UIColor(hexString: "003399")!),
     LineColor(line: "V", color: UIColor(hexString: "FF6600")!),
     LineColor(line: "W", color: UIColor(hexString: "003399")!),
     LineColor(line: "XA", color: UIColor(hexString: "969391")!),
     LineColor(line: "X", color: UIColor(hexString: "003399")!),
     LineColor(line: "Y", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "Z", color: UIColor(hexString: "FF9999")!),
     LineColor(line: "80", color: UIColor(hexString: "000000")!),
     LineColor(line: "81", color: UIColor(hexString: "000000")!),
     LineColor(line: "82", color: UIColor(hexString: "000000")!),
     LineColor(line: "83", color: UIColor(hexString: "000000")!),
     LineColor(line: "84", color: UIColor(hexString: "000000")!),
     LineColor(line: "85", color: UIColor(hexString: "000000")!),
     LineColor(line: "86", color: UIColor(hexString: "000000")!),
     LineColor(line: "92", color: UIColor(hexString: "000000")!),
     LineColor(line: "93", color: UIColor(hexString: "000000")!),
     LineColor(line: "94", color: UIColor(hexString: "000000")!),
     LineColor(line: "96", color: UIColor(hexString: "000000")!),
     LineColor(line: "97", color: UIColor(hexString: "000000")!)]
  
  private static var tacLinesColor: [LineColor] =
    [LineColor(line: "R", color: UIColor(hexString: "d21513")!),
     LineColor(line: "T2", color: UIColor(hexString: "2083be")!),
     LineColor(line: "3", color: UIColor(hexString: "00ad93")!),
     LineColor(line: "4", color: UIColor(hexString: "fabb60")!),
     LineColor(line: "5", color: UIColor(hexString: "ab4793")!),
     LineColor(line: "6", color: UIColor(hexString: "deda51")!),
     LineColor(line: "7", color: UIColor(hexString: "b47231")!),
     LineColor(line: "DA", color: UIColor(hexString: "40655b")!)]
  
  static func color(for lineCode: String,
                    operator stopOperator: Operator = .tpg) -> UIColor {
    var color: UIColor
    switch stopOperator {
    case .tpg:
      color = self.tpgLinesColor.filter({ $0.line == lineCode })[safe: 0]?.color
        ?? (App.darkMode ? .white : .black)
    case .tac:
      color = self.tacLinesColor.filter({ $0.line == lineCode })[safe: 0]?.color
        ?? (App.darkMode ? .white : .black)
    }
    if color.contrast != .white, !App.darkMode {
      color = color.darken(by: 0.2)
    } else if color.contrast != .black, App.darkMode {
      return color.lighten(by: 0.3)
    }
    return color
  }
}

struct LineColor {
  var line: String
  var color: UIColor
}
