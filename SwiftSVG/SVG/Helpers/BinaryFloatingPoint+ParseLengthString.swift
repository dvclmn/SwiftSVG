//
//  FloatingPoint+ParseLengthString.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

/// Extension that takes a length string, e.g. `100px`, `20mm` and parses it into a `BinaryFloatingPoint` (e.g. `Float`, `Double`, `CGFloat`)
extension BinaryFloatingPoint {

  /// Parses a number string with optional suffix, such as `px`, `mm`
  internal init?(lengthString: String) {

    let simpleNumberClosure: (String) -> Double? = { (string) -> Double? in
      return Double(string)
    }

    if let thisNumber = simpleNumberClosure(lengthString) {
      self.init(thisNumber)
      return
    }

    let numberFromSupportedSuffix: (String, String) -> Double? = { (string, suffix) -> Double? in
      if string.hasSuffix(suffix) {
        return simpleNumberClosure(string[0..<string.count - suffix.count])
      }
      return nil
    }

    if let withPxAnnotation = numberFromSupportedSuffix(lengthString, "px") {
      self.init(withPxAnnotation)
      return
    }

    if let withMmAnnotation = numberFromSupportedSuffix(lengthString, "mm") {
      self.init(withMmAnnotation)
      return
    }

    return nil
  }

}
