//
//  SVGParser.swift
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

/// A protocol describing an XML parser capable of parsing SVG data
public protocol SVGParser {

  /// Initializer to create a new `SVGParser` instance
  /// - parameters:
  ///    - SVGData: SVG file as Data
  ///    - supportedElements: The elements and corresponding attribiutes the parser can parse
  ///    - completion: A closure to execute after the parser has completed parsing and processing the SVG
  init(
    svgData: Data,
    supportedElements: SVGParserSupportedElements?,
    completion: SVGCompletion?
  )

  /// A closure that is executed after all elements have been processed. Should be guaranteed to be executed after all elements have been processed, even if parsing asynchronously.
  var completionBlock: SVGCompletion? { get }

  /// A struct listing all the elements and its attributes that should be parsed
  var supportedElements: SVGParserSupportedElements? { get }

  /// A `CALayer` that will house the finished sublayers of the SVG doc.
  var containerLayer: SVGLayer { get }

  /// Starts parsing the SVG. Allows you to separate initialization from parse start in case you want to set some things up first.
  /// A successful `completionBlock` invocation is the boundary at which the returned layer hierarchy is fully assembled.
  func startParsing()
}
