//
//  SVGPolygon.swift
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

/// Concrete implementation that creates a `CAShapeLayer` from a `<polygon>` element and its attributes

struct SVGPolygon: SVGShapeElement {

  internal static let elementName = "polygon"
  internal var supportedAttributes: SVGAttributes = [:]
  internal var svgLayer = CAShapeLayer()

  /// Function that parses a coordinate string and creates a polygon path
  internal func points(points: String) {
    let polylinePath = UIBezierPath()
    for (index, thisPoint) in CoordinateLexer(coordinateString: points).enumerated() {
      if index == 0 {
        polylinePath.move(to: thisPoint)
      } else {
        polylinePath.addLine(to: thisPoint)
      }
    }
    polylinePath.close()
    self.svgLayer.path = polylinePath.cgPath
  }

  internal func didProcessElement(in container: SVGContainerElement?) {
    guard let container = container else {
      return
    }
    container.containerLayer.addSublayer(self.svgLayer)
  }
}
