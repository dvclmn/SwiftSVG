//
//  FloatingPoint+DegreesRadians.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
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
