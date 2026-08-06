//
//  SVGRootElement.swift
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

public typealias SVGAttributes = [String: (String) -> Void]

/// Concrete implementation that creates a container from a `<svg>` element and its attributes.
/// This will almost always be the root container element that will container all other `SVGElement` layers
struct SVGRootElement: SVGContainerElement {

  internal static let elementName = "svg"
  internal var delayedAttributes: [String: String] = [:]
  internal var containerLayer = CALayer()
  internal var supportedAttributes: SVGAttributes = [:]

  /// Applies the renderer's legacy root-layer frame deterministically after all relevant root
  /// attributes have been parsed into separate values.
  ///
  /// A viewBox remains the preferred rendering rectangle for compatibility. Consumers that need
  /// authored document dimensions should read `SVGLayer.rootAttributes` instead of this frame.
  internal func apply(_ attributes: SVGRootAttributes) {
    if let viewBox = attributes.viewBox {
      self.containerLayer.frame = viewBox
      return
    }

    if let viewportSize = attributes.viewportSize {
      self.containerLayer.frame = CGRect(origin: .zero, size: viewportSize)
    }
  }

  internal func didProcessElement(in container: SVGContainerElement?) {
    return
  }

}

extension SVGRootElement: CustomStringConvertible {
  var description: String {
    """
    Element Name: \(Self.elementName)
    Delayed Attributes: \(delayedAttributes.prettyPrinted())
    Supported Attributes: \(supportedAttributes.debugString)
    """
  }
}
