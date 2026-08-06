//
//  SVGLine.swift
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

/// Concrete implementation that creates a `CAShapeLayer` from a `<line>` element and its attributes

final class SVGLine: SVGShapeElement {

  internal static let elementName = "line"

  /// The line's end point. Defaults to `CGPoint.zero`
  internal var end = CGPoint.zero

  /// The line's end point. Defaults to `CGPoint.zero`
  internal var start = CGPoint.zero
  internal var svgLayer = CAShapeLayer()
  internal var supportedAttributes: SVGAttributes = [:]

  /// Function parses a number string and sets this line's start `x`
  internal func x1(x1: String) {
    guard let x1 = CGFloat(x1) else {
      return
    }
    self.start.x = x1
  }

  /// Function parses a number string and sets this line's end `x`
  internal func x2(x2: String) {
    guard let x2 = CGFloat(x2) else {
      return
    }
    self.end.x = x2
  }

  /// Function parses a number string and sets this line's start `y`
  internal func y1(y1: String) {
    guard let y1 = CGFloat(y1) else {
      return
    }
    self.start.y = y1
  }

  /// Function parses a number string and sets this line's end `y`
  internal func y2(y2: String) {
    guard let y2 = CGFloat(y2) else {
      return
    }
    self.end.y = y2
  }

  /// Draws a line from the `startPoint` to the `endPoint`
  internal func didProcessElement(in container: SVGContainerElement?) {
    guard let container = container else {
      return
    }
    let linePath = UIBezierPath()
    linePath.move(to: self.start)
    linePath.addLine(to: self.end)
    self.svgLayer.path = linePath.cgPath
    container.containerLayer.addSublayer(self.svgLayer)
  }

}
