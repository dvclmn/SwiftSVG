//
//  Scalar+FromByteArray.swift
//  SwiftSVGiOS
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import CoreGraphics

extension CGFloat {

  /// Initializer that creates a new CGFloat from a String
  internal init?(_ string: String) {
    guard let asDouble = Double(string) else {
      return nil
    }
    self.init(asDouble)
  }

  /// Initializer that creates a new CGFloat from a Character byte array with the option to set the base.
  internal init?(byteArray: [CChar], base: Int32 = 10) {
    var nullTerminated = byteArray
    nullTerminated.append(0)
    self.init(strtol(nullTerminated, nil, base))
  }

}

extension Float {

  /// Initializer that creates a new Float from a Character byte array
  internal init?(byteArray: [CChar]) {

    guard byteArray.count > 0 else {
      return nil
    }
    var nullTerminated = byteArray
    nullTerminated.append(0)
    var error: UnsafeMutablePointer<Int8>? = nil
    let result = strtof(nullTerminated, &error)
    if error != nil && error?.pointee != 0 {
      return nil
    }
    self = result
  }

}

extension Double {

  /// Initializer that creates a new Double from a Character byte array
  internal init?(byteArray: [CChar]) {

    guard byteArray.count > 0 else {
      return nil
    }
    var nullTerminated = byteArray
    nullTerminated.append(0)
    var error: UnsafeMutablePointer<Int8>? = nil
    let result = strtod(nullTerminated, &error)
    if error != nil && error?.pointee != 0 {
      return nil
    }
    self = result
  }
}
