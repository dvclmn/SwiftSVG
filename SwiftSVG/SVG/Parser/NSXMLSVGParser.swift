//
//  NSXMLSVGParser.swift
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

/// `NSXMLSVGParser` conforms to `SVGParser`
extension NSXMLSVGParser: SVGParser {}

/// Concrete implementation of `SVGParser` that uses Foundation's `XMLParser` to parse a given SVG file.
open class NSXMLSVGParser: XMLParser, XMLParserDelegate {

  /// Error type used when a fatal error has occured
  enum SVGParserError {
    case invalidSVG
    case invalidURL
  }

  package var asyncParseCount: Int = 0
  package var didDispatchAllElements = true
  var elementStack = Stack<SVGElement>()

  public var completionBlock: SVGResult?
  public var supportedElements: SVGParserSupportedElements? = nil

  /// The `SVGLayer` that will contain all of the SVG's sublayers
  open var containerLayer = SVGLayer()

  let asyncCountQueue = DispatchQueue(
    label: "com.straussmade.swiftsvg.asyncCountQueue.serial",
    qos: .userInteractive
  )

  private init() {
    super.init(data: Data())
  }

  /// Initializer that can initalize an `NSXMLSVGParser` using SVG `Data`
  /// - parameter svgURL: The URL of the SVG.
  /// - parameter supportedElements: Optional `SVGParserSupportedElements`
  ///   struct that restricts the elements and attributes that this parser can parse. If no value is
  ///   provided, all supported attributes will be used.
  /// - parameter completion: Optional completion block that will be executed after all
  ///   elements and attribites have been parsed.
  public required init(
    svgData: Data,
    supportedElements: SVGParserSupportedElements? = .allSupportedElements,
    completion: SVGResult? = nil
  ) {
    super.init(data: svgData)
    self.delegate = self
    self.supportedElements = supportedElements
    self.completionBlock = completion
  }
}

extension NSXMLSVGParser {

  /// Convenience initializer that can initalize an `NSXMLSVGParser` using a local or remote `URL`
  /// - parameter svgURL: The URL of the SVG.
  /// - parameter supportedElements: Optional `SVGParserSupportedElements`
  ///   struct that restrict the elements and attributes that this parser can parse.If no value is provided,
  ///   all supported attributes will be used.
  /// - parameter completion: Optional completion block that will be executed after all
  ///   elements and attribites have been parsed.
  public convenience init(
    svgURL: URL,
    supportedElements: SVGParserSupportedElements? = nil,
    completion: SVGResult? = nil
  ) {
    do {
      let urlData = try Data(contentsOf: svgURL)
      self.init(
        svgData: urlData,
        supportedElements: supportedElements,
        completion: completion
      )
    } catch {
      self.init()
      print("Couldn't get data from URL. Error: \(error)")
    }
  }
}

// MARK: - Deprecations
extension NSXMLSVGParser {

  @available(*, deprecated, renamed: "init(svgURL:supportedElements:completion:)")
  public convenience init(
    SVGURL: URL,
    supportedElements: SVGParserSupportedElements? = nil,
    completion: SVGResult? = nil
  ) {
    self.init(svgURL: SVGURL, supportedElements: supportedElements, completion: completion)
  }

  @available(*, deprecated, renamed: "init(svgData:supportedElements:completion:)")
  public convenience init(
    SVGData: Data,
    supportedElements: SVGParserSupportedElements? = .allSupportedElements,
    completion: SVGResult? = nil
  ) {
    self.init(svgData: SVGData, supportedElements: supportedElements, completion: completion)
  }
}

extension NSXMLSVGParser {

  /// Method that resizes the container bounding box that fits all the subpaths.
  func resizeContainerBoundingBox(_ boundingBox: CGRect?) {
    guard let thisBoundingBox = boundingBox else {
      return
    }
    self.containerLayer.boundingBox = self.containerLayer.boundingBox.union(thisBoundingBox)
  }
}

/// `NSXMLSVGParser` conforms to the protocol `CanManageAsychronousParsing` that
/// uses a simple reference count to see if there are any pending asynchronous tasks that have been
/// dispatched and are still being processed. Once the element has finished processing, the asynchronous
/// elements calls the delegate callback `func finishedProcessing(shapeLayer:)`
/// and the delegate will decrement the count.
extension NSXMLSVGParser: CanManageAsychronousParsing {

  /// The `CanManageAsychronousParsing` callback called when an
  /// `ParsesAsynchronously` element has finished parsing
  func finishedProcessing(_ shapeLayer: CAShapeLayer, shouldResizeBounds: Bool) {

    self.asyncCountQueue.sync {
      self.asyncParseCount -= 1
    }

    if shouldResizeBounds {
      self.resizeContainerBoundingBox(shapeLayer.path?.boundingBox)
    }

    guard self.asyncParseCount <= 0 && self.didDispatchAllElements else {
      return
    }
    DispatchQueue.main.safeAsync {
      self.completionBlock?(.success(self.containerLayer))
      self.completionBlock = nil
    }
  }

}
