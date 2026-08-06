//
//  SVGEllipse.swift
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

/// Concrete implementation that creates a `CAShapeLayer` from a `<ellipse>` element and its attributes
final class SVGEllipse: SVGShapeElement {

  internal static let elementName = "ellipse"

  /// The ellipse's center point. Defaults to `CGRect.zero`
  internal var ellipseCenter = CGPoint.zero

  /// The ellipse's x radius. Defaults to `CGRect.zero`
  internal var xRadius: CGFloat = 0

  /// The ellipse's x radius. Defaults to `CGRect.zero`
  internal var yRadius: CGFloat = 0
  internal var svgLayer = CAShapeLayer()
  internal var supportedAttributes: SVGAttributes = [:]

  /// Function that parses the number string and sets this instance's x radius
  internal func xRadius(r: String) {
    guard let r = CGFloat(lengthString: r) else {
      return
    }
    self.xRadius = r
  }

  /// Function that parses the number string and sets this instance's y radius
  internal func yRadius(r: String) {
    guard let r = CGFloat(lengthString: r) else {
      return
    }
    self.yRadius = r
  }

  /// Function that parses the number string and sets this instance's x center
  internal func xCenter(x: String) {
    guard let x = CGFloat(lengthString: x) else {
      return
    }
    self.ellipseCenter.x = x
  }

  /// Function that parses the number string and sets this instance's y center
  internal func yCenter(y: String) {
    guard let y = CGFloat(lengthString: y) else {
      return
    }
    self.ellipseCenter.y = y
  }

  /// Function that is called after the ellipse's center and radius have been parsed and set. This function creates the path and sets the internal `SVGLayer`'s path.
  internal func didProcessElement(in container: SVGContainerElement?) {
    
    guard let container = container else { return }
    let ellipseRect = CGRect(
      x: self.ellipseCenter.x - self.xRadius,
      y: self.ellipseCenter.y - self.yRadius,
      width: 2 * self.xRadius,
      height: 2 * self.yRadius
    )
    let circlePath = UIBezierPath(ovalIn: ellipseRect)
    self.svgLayer.path = circlePath.cgPath
    container.containerLayer.addSublayer(self.svgLayer)
  }

}
