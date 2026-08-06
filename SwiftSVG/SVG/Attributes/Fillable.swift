//
//  Fillable.swift
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

/// A protocol that described an instance that can be filled. Two default implementations are provided for this protocol:
/// 1. `SVGShapeElement` - Will set the fill color, fill opacity, and fill rule on the underlying `SVGLayer` which is a subclass of `CAShapeLayer`
/// 2. `SVGGroup` - Will set the fill color, fill opacity, and fill rule of all of a `SVGGroup`'s subelements
public protocol Fillable {}

/// Default implementation for fill attributes on `SVGShapeElement`s
extension Fillable where Self: SVGShapeElement {

  /// The curried functions to be used for the `SVGShapeElement`'s default implementation. This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  /// - parameter Key: The SVG string value of the attribute
  /// - parameter Value: A curried function to use to implement the SVG attribute
  var fillAttributes: SVGAttributes {
    return [
      "color": self.fill,
      "fill": self.fill,
      "fill-opacity": self.fillOpacity,
      "fill-rule": self.fillRule,
      "opacity": self.fillOpacity,
    ]
  }

  /// Sets the fill color of the underlying `SVGLayer`
  /// - SeeAlso: CAShapeLayer's [`fillColor`](https://developer.apple.com/documentation/quartzcore/cashapelayer/1522248-fillcolor)
  func fill(fillColor: String) {
    guard let colorComponents = self.svgLayer.fillColor?.components else {
      return
    }
    guard let fillColor = UIColor(svgString: fillColor) else {
      return
    }
    self.svgLayer.fillColor = fillColor.withAlphaComponent(colorComponents[3]).cgColor
  }

  /// Sets the fill rule of the underlying `SVGLayer`. `CAShapeLayer`s have 2 possible values: `non-zero` (default), and `evenodd`
  /// - SeeAlso: Core Animation's [Shape Fill Mode Value](https://developer.apple.com/documentation/quartzcore/cashapelayer/shape_fill_mode_values)
  func fillRule(fillRule: String) {
    guard fillRule == "evenodd" else {
      return
    }
    self.svgLayer.fillRule = CAShapeLayerFillRule.evenOdd
  }

  /// Sets the fill opacity of the underlying `SVGLayer` through its CGColor, not the CALayer's opacity property. This value will override any opacity value passed in with the `fill-color` attribute.
  func fillOpacity(opacity: String) {
    guard let opacity = CGFloat(opacity) else {
      return
    }
    guard let colorComponents = self.svgLayer.fillColor?.components else {
      return
    }
    self.svgLayer.fillColor =
      UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: opacity)
      .cgColor
  }

}

/// Default implementation for fill attributes on `SVGGroup`s
extension Fillable where Self: SVGGroup {

  ///The curried functions to be used for the `SVGGroup`'s default implementation. This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  var fillAttributes: SVGAttributes {
    return [
      "color": unown(self, SVGGroup.fill),
      "fill": unown(self, SVGGroup.fill),
      "fill-opacity": unown(self, SVGGroup.fillOpacity),
      "fill-rule": unown(self, SVGGroup.fillRule),
      "opacity": unown(self, SVGGroup.fillOpacity),
    ]
  }

  /// Sets the fill color for all subelements of the `SVGGroup`
  func fill(_ fillColor: String) {
    self.delayedAttributes["fill"] = fillColor
  }

  /// Sets the fill rule for all subelements of the `SVGGroup`. `CAShapeLayer`s have 2 possible values: `non-zero` (default), and `evenodd`
  /// - SeeAlso: Core Animation's [Shape Fill Mode Value](https://developer.apple.com/documentation/quartzcore/cashapelayer/shape_fill_mode_values)
  func fillRule(_ fillRule: String) {
    self.delayedAttributes["fill-rule"] = fillRule
  }

  /// Sets the fill opacity for all subelements of the `SVGGroup` through its CGColor, not the CALayer's opacity property.
  func fillOpacity(_ opacity: String) {
    self.delayedAttributes["opacity"] = opacity
  }

}
