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

  /// Function that parses a number string and sets the `containerLayer`'s width
  internal func parseWidth(lengthString: String) {
    if let width = CGFloat(lengthString: lengthString) {
      print("Setting `SVGRootElement/containerLayer/frame` width to \(width)")
      self.containerLayer.frame.size.width = width
    }
  }

  /// Function that parses a number string and sets the `containerLayer`'s height
  internal func parseHeight(lengthString: String) {
    if let height = CGFloat(lengthString: lengthString) {
      print("Setting `SVGRootElement/containerLayer/frame` height to \(height)")
      self.containerLayer.frame.size.height = height
    }
  }

  internal func didProcessElement(in container: SVGContainerElement?) {
    return
  }

  internal func viewBox(coordinates: String) {
    let points =
      coordinates
      .components(separatedBy: CharacterSet(charactersIn: ", "))
      .compactMap { (thisString) -> Double? in
        return Double(thisString.trimWhitespace())
      }
//    print("View box results: \(points). OG string: \(coordinates)")
    guard points.count == 4 else {
      return
    }
    self.containerLayer.frame = CGRect(
      x: points[0],
      y: points[1],
      width: points[2],
      height: points[3]
    )
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

extension Dictionary where Key == String {
  public var debugString: String {
    "\(.indentString + keys.joined(separator: .indentString))"
  }
}
