//
//  SiriExtensions.swift
//  tpg offline - Siri
//
//  Created by Rémy on 14/06/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit

extension String {
  var time: String {
    if Int(self) ?? 0 > 60 {
      let hour = (Int(self) ?? 0) / 60
      let minutes = (Int(self) ?? 0) % 60
      return "\(hour)h\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
    } else {
      return self
    }
  }

  var accessibleTime: String {
    if Int(self) ?? 0 > 60 {
      let hour = (Int(self) ?? 0) / 60
      let minutes = (Int(self) ?? 0) % 60
      return String(format: "%@ hours %@".localized, "\(hour)",
        minutes < 10 ? "0\(minutes)" : "\(minutes)")
    } else {
      return self
    }
  }

  static func random(_ length: Int) -> String {

    let letters: NSString =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
      let rand = arc4random_uniform(len)
      var nextChar = letters.character(at: Int(rand))
      randomString += NSString(characters: &nextChar, length: 1) as String
    }

    return randomString
  }

  var escaped: String {
    let listOfOccurencies = [
      "berner": "bernex",
      "on est": "onex",
      "nancy": "lancy",
      "cinq": "st",
      "saint": "st",
      "argent": "archamps",
      "veuillat": "feuillat",
      "plus air": "r",
      "plus r": "r"
    ]
    var p = self
      .folding(options: NSString.CompareOptions.diacriticInsensitive,
               locale: Locale.current)
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "+", with: "")
      .replacingOccurrences(of: "-", with: "")
      .lowercased()
    for (k, v) in listOfOccurencies {
      p = p.replacingOccurrences(of: k, with: v)
    }
    return p
  }

  var localized: String {
    return NSLocalizedString(self,
                             tableName: nil,
                             bundle: Bundle.main,
                             value: "",
                             comment: "")
  }

  func score(word: String, fuzziness: Double? = nil) -> Double {

    // If the string is equal to the word, perfect match.
    if self == word {
      return 1
    }

    //if it's not a perfect match and is empty return 0
    if word.isEmpty || self.isEmpty {
      return 0
    }

    var
    runningScore = 0.0,
    charScore = 0.0,
    finalScore = 0.0,
    string = self,
    lString = string.lowercased(),
    strLength = string.count,
    lWord = word.lowercased(),
    wordLength = word.count,
    idxOf: String.Index!,
    startAt = lString.startIndex,
    fuzzies = 1.0,
    fuzzyFactor = 0.0,
    fuzzinessIsNil = true

    // Cache fuzzyFactor for speed increase
    if let fuzziness = fuzziness {
      fuzzyFactor = 1 - fuzziness
      fuzzinessIsNil = false
    }

    for i in 0 ..< wordLength {
      // Find next first case-insensitive match of word's i-th character.
      // The search in "string" begins at "startAt".

      if let range = lString.range(of:
        String(lWord[lWord.index(lWord.startIndex, offsetBy: i)] as Character),
                                   options: NSString.CompareOptions.caseInsensitive,
                                   range: (startAt..<lString.endIndex),
                                   locale: nil
        ) {
        // start index of word's i-th character in string.
        idxOf = range.lowerBound
        if startAt == idxOf {
          // Consecutive letter & start-of-string Bonus
          charScore = 0.7
        } else {
          charScore = 0.1

          // Acronym Bonus
          // Weighing Logic: Typing the first character of an acronym is as if you
          // preceded it with two perfect character matches.
          if string[string.index(idxOf, offsetBy: -1)] == " " {
            charScore += 0.8
          }
        }
      } else {
        // Character not found.
        if fuzzinessIsNil {
          // Fuzziness is nil. Return 0.
          return 0
        } else {
          fuzzies += fuzzyFactor
          continue
        }
      }

      // Same case bonus.
      if string[idxOf] == word[word.index(word.startIndex, offsetBy: i)] {
        charScore += 0.1
      }

      // Update scores and startAt position for next round of indexOf
      runningScore += charScore
      startAt = string.index(idxOf, offsetBy: 1)
    }

    // Reduce penalty for longer strings.
    finalScore = 0.5
      * (runningScore / Double(strLength) + runningScore / Double(wordLength))
      / fuzzies

    if (lWord[lWord.startIndex] == lString[lString.startIndex]),
      (finalScore < 0.85) {
      finalScore += 0.15
    }

    return finalScore
  }
}

extension Collection {
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension Array {
  mutating func rearrange(from: Int, to: Int) {
    insert(remove(at: from), at: to)
  }
}

public extension Sequence where Iterator.Element: Hashable {
  var uniqueElements: [Iterator.Element] {
    return Array( Set(self) )
  }
}
public extension Sequence where Iterator.Element: Equatable {
  var uniqueElements: [Iterator.Element] {
    return self.reduce([]) { uniqueElements, element in

      uniqueElements.contains(element)
        ? uniqueElements
        : uniqueElements + [element]
    }
  }
}

extension UIColor {
  func lighten(by percentage: CGFloat=0.3) -> UIColor {
    return self.adjust(by: abs(percentage) )
  }

  func darken(by percentage: CGFloat=0.3) -> UIColor {
    return self.adjust(by: -1 * abs(percentage) )
  }

  func adjust(by percentage: CGFloat=0.3) -> UIColor {
    var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
    if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
      return UIColor(red: min(r + percentage, 1.0),
                     green: min(g + percentage, 1.0),
                     blue: min(b + percentage, 1.0),
                     alpha: a)
    } else {
      print("Color adjustement failed")
      return self
    }
  }

  public var contrast: UIColor {
    var color = self

    if cgColor.pattern != nil {
      let size = CGSize(width: 1, height: 1)

      UIGraphicsBeginImageContext(size)
      let context = UIGraphicsGetCurrentContext()

      context?.interpolationQuality = .medium

      let image = UIImage()
      image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size),
                 blendMode: .copy,
                 alpha: 1)

      let dataPointer = context?.data?.assumingMemoryBound(to: UInt8.self)
      let data = UnsafePointer<UInt8>(dataPointer)
      color = UIColor(red: CGFloat(data![2] / 255),
                      green: CGFloat(data![1] / 255),
                      blue: CGFloat(data![0] / 255),
                      alpha: 1)

      UIGraphicsEndImageContext()
    }

    var luminance: CGFloat = 0
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha1: CGFloat = 0

    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha1)

    red *= 0.2126
    green *= 0.7152
    blue *= 0.0722

    luminance = red + green + blue

    return luminance > 0.6 ? .black : .white
  }

  convenience init?(hexString: String) {
    var cString: String = hexString
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .uppercased()

    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }

    if (cString.count) != 6 {
      return nil
    }

    var rgbValue: UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: CGFloat(1.0))
  }

  var hexValue: String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0

    self.getRed(&r, green: &g, blue: &b, alpha: &a)

    return String(
      format: "#%02X%02X%02X",
      Int(r * 0xff),
      Int(g * 0xff),
      Int(b * 0xff)
    )
  }
}

struct App {
  static var apnsToken = ""
  static var automaticDeparturesDownload = true
  static var stops: [Stop] = []
  static var darkMode = false
  static var intentsVersionNumber: NSNumber = 1.0
}
