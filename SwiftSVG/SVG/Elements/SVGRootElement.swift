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
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
