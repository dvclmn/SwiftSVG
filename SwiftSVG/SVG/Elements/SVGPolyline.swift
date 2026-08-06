//
//  SVGPolyline.swift
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

/// Concrete implementation that creates a `CAShapeLayer` from a `<polyline>` element and its attributes

struct SVGPolyline: SVGShapeElement {

  internal static let elementName = "polyline"
  internal var supportedAttributes: SVGAttributes = [:]
  internal var svgLayer = CAShapeLayer()

  /// Parses a coordinate string and creates a new polyline based on them
  internal func points(points: String) {
    let polylinePath = UIBezierPath()
    for (index, thisPoint) in CoordinateLexer(coordinateString: points).enumerated() {
      if index == 0 {
        polylinePath.move(to: thisPoint)
      } else {
        polylinePath.addLine(to: thisPoint)
      }
    }
    self.svgLayer.path = polylinePath.cgPath
  }

  internal func didProcessElement(in container: SVGContainerElement?) {
    guard let container = container else {
      return
    }
    container.containerLayer.addSublayer(self.svgLayer)
  }
}
