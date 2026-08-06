//
//  CAShapeLayer+SVG.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension CAShapeLayer {

  /// Convenience initalizer that synchronously parses a single path string and returns a `CAShapeLayer`
  /// - Parameter pathString: The path `d` string to parse.
  public convenience init(pathString: String) {
    self.init()
    let singlePath = SVGPath(singlePathString: pathString)
    self.path = singlePath.svgLayer.path
  }
}
