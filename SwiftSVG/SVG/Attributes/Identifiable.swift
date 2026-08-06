//
//  Identifiable
//  SwiftSVG
//
//
//  Thanks to Oliver Jones (@orj) for adding this.
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

public protocol Identifiable {}

extension Identifiable where Self: SVGShapeElement {

  /// The curried functions to be used for the `SVGShapeElement`'s default implementation.
  /// This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  /// - parameter Key: The SVG string value of the attribute
  /// - parameter Value: A curried function to use to implement the SVG attribute
  var identityAttributes: SVGAttributes {
    return ["id": self.identify]
  }

  /// Sets the identifier of the underlying `SVGLayer`.
  /// - SeeAlso: CALayer's [`name`](https://developer.apple.com/documentation/quartzcore/calayer/1410879-name) property
  func identify(identifier: String) {
    self.svgLayer.name = identifier
  }
}

extension Identifiable where Self: SVGGroup {
  /// The curried functions to be used for the `SVGShapeElement`'s default implementation.
  /// This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  /// - parameter Key: The SVG string value of the attribute
  /// - parameter Value: A curried function to use to implement the SVG attribute
  var identityAttributes: SVGAttributes {
    return ["id": unown(self, SVGGroup.identify)]
  }
}

extension Identifiable where Self: SVGContainerElement {

  /// The curried functions to be used for the `SVGShapeElement`'s default implementation.
  /// This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  /// - parameter Key: The SVG string value of the attribute
  /// - parameter Value: A curried function to use to implement the SVG attribute
  var identityAttributes: SVGAttributes {
    return ["id": self.identify]
  }

  /// Sets the identifier of the underlying `SVGLayer`.
  /// - SeeAlso: CALayer's [`name`](https://developer.apple.com/documentation/quartzcore/calayer/1410879-name) property
  func identify(identifier: String) {
    self.containerLayer.name = identifier
  }
}
