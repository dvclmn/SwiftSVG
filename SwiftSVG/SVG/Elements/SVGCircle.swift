//
//  SVGCircle.swift
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

/// Concrete implementation that creates a `CAShapeLayer` from a `<circle>` element and its attributes
final class SVGCircle: SVGShapeElement {

  internal static let elementName = "circle"

  /// The circle's center point. Defaults to `CGRect.zero`
  internal var circleCenter = CGPoint.zero

  /// The circle's radius. Defaults to `0`
  internal var circleRadius: CGFloat = 0
  internal var svgLayer = CAShapeLayer()
  internal var supportedAttributes: SVGAttributes = [:]

  /// Function that parses the number string and sets this instance's radius
  internal func radius(r: String) {
    guard let r = CGFloat(lengthString: r) else { return }
    self.circleRadius = r
  }

  /// Function that parses the number string and sets this instance's x center
  internal func xCenter(x: String) {
    guard let x = CGFloat(lengthString: x) else { return }
    self.circleCenter.x = x
  }

  /// Function that parses the number string and sets this instance's y center
  internal func yCenter(y: String) {
    guard let y = CGFloat(lengthString: y) else { return }
    self.circleCenter.y = y
  }

  /// Function that is called after the circle's center and radius have been parsed and set.
  /// This function creates the path and sets the internal `SVGLayer`'s path.
  internal func didProcessElement(in container: SVGContainerElement?) {
    guard let container = container else { return }

    #if os(iOS) || os(tvOS)
    let circlePath = UIBezierPath(
      arcCenter: self.circleCenter,
      radius: self.circleRadius,
      startAngle: 0,
      endAngle: CGFloat.pi * 2,
      clockwise: true
    )
    #elseif os(OSX)
    let circleRect = CGRect(
      x: self.circleCenter.x - self.circleRadius,
      y: self.circleCenter.y - self.circleRadius,
      width: self.circleRadius * 2,
      height: self.circleRadius * 2
    )
    let circlePath = NSBezierPath(ovalIn: circleRect)
    #endif
    self.svgLayer.path = circlePath.cgPath
    container.containerLayer.addSublayer(self.svgLayer)
  }
}

extension SVGCircle: CustomStringConvertible {
  public var description: String {
    """
    Element Name: \(Self.elementName)
    Circle Center: \(circleCenter)
    Circle Radius: \(circleRadius)
    Supported Attributes: \(supportedAttributes.debugString)
    """
  }
}
