//
//  SVGShapeElement.swift
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

/// A protocol that describes an instance that stores the path as a `CAShapeLayer`
public protocol SVGShapeElement: SVGElement, Fillable, Strokable, Transformable, Stylable, Identifiable {

  /// The `CAShapeLayer` that can draw the path data.
  var svgLayer: CAShapeLayer { get set }
}

extension SVGShapeElement {

  /// The minimum rect that encompasses all of the subpaths
  var boundingBox: CGRect? {
    return self.svgLayer.path?.boundingBox
  }
}
