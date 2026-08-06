//
//  CALayer+Sublayers.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// Helper functions that make it easier to find and work with sublayers
extension CALayer {

  /// Helper function that applies the given closure on all sublayers of a given type
  public func applyOnSublayers<T: CALayer>(ofType: T.Type, closure: (T) -> Void) {
    _ = self.sublayers(in: self).map(closure)
  }

  /// Helper function that returns an array of all sublayers of a given type
  public func sublayers<T: CALayer, U>(in layer: T) -> [U] {

    var sublayers: [U] = []

    guard let allSublayers = layer.sublayers else {
      return sublayers
    }

    for thisSublayer in allSublayers {
      sublayers += self.sublayers(in: thisSublayer)
      if let thisSublayer = thisSublayer as? U {
        sublayers.append(thisSublayer)
      }
    }
    return sublayers
  }
}
