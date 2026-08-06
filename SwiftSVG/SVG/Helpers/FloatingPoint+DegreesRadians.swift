//
//  FloatingPoint+DegreesRadians.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

/// Extension that converts a `FloatingPoint` to and from radians and degrees
extension FloatingPoint {

  /// Converts a `FloatingPoint` type to radians
  public var toRadians: Self {
    return self * .pi / 180
  }

  /// Converts a `FloatingPoint` type to degrees
  public var toDegrees: Self {
    return self * 180 / .pi
  }
}
