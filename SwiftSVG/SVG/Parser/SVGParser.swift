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

/// A callback invoked when SVG parsing and layer assembly succeeds or fails.
public typealias SVGCompletion = (Result<SVGLayer, Error>) -> Void

@available(*, deprecated, renamed: "SVGCompletion")
public typealias SVGResult = SVGCompletion

/// The namespace policy used while parsing the SVG document.
public enum SVGNamespaceMode: Equatable, Sendable {
  /// The document declared the SVG XML namespace and was parsed as a conforming SVG XML document.
  case svg

  /// The document omitted the SVG XML namespace and was accepted using SwiftSVG's compatibility path.
  case unnamespacedCompatibility
}


/// Typed, non-fatal information produced with a successfully rendered SVG document.
public struct SVGParseReport: Equatable, Sendable {
  /// The namespace policy that admitted the document.
  public let namespaceMode: SVGNamespaceMode

  /// Conditions which did not prevent rendering, but are useful to a host application or editor.
  public let diagnostics: [SVGParseDiagnostic]

  /// Whether parsing completed with information a host may wish to surface.
  public var hasDiagnostics: Bool {
    !self.diagnostics.isEmpty
  }

  public init(namespaceMode: SVGNamespaceMode, diagnostics: [SVGParseDiagnostic]) {
    self.namespaceMode = namespaceMode
    self.diagnostics = diagnostics
  }
}

/// The fully assembled renderer layer and its typed parse report.
public struct SVGParseResult {
  /// The layer hierarchy that SwiftSVG produced.
  public let layer: SVGLayer

  /// Information about how that layer hierarchy was produced.
  public let report: SVGParseReport

  public init(layer: SVGLayer, report: SVGParseReport) {
    self.layer = layer
    self.report = report
  }
}

/// A callback invoked when SVG parsing completes with both the rendered layer and parse report.
public typealias SVGParseCompletion = (Result<SVGParseResult, Error>) -> Void

/// An error that prevents SwiftSVG from producing a renderable document.
public enum SVGParserError: Error, Equatable, LocalizedError, Sendable {
  /// The XML document's root element was not an SVG root in a supported namespace.
  case invalidRootElement(name: String, namespaceURI: String?)

  /// The document did not yield a root SVG layer.
  case missingRootSVGElement

  public var errorDescription: String? {
    switch self {
      case .invalidRootElement(let name, let namespaceURI):
        if let namespaceURI {
          "Expected an SVG root element, but found <\(name)> in the \(namespaceURI) namespace."
        } else {
          "Expected an SVG root element, but found <\(name)> without a namespace."
        }
      case .missingRootSVGElement:
        "The document did not produce an SVG root element."
    }
  }
}

/// A protocol describing an XML parser capable of parsing SVG data
public protocol SVGParser {

  /// Initializer to create a new `SVGParser` instance
  /// - parameters:
  ///    - SVGData: SVG file as Data
  ///    - supportedElements: The elements and corresponding attribiutes the parser can parse
  ///    - completion: A closure to execute after the parser has completed parsing and processing the SVG
  init(svgData: Data, supportedElements: SVGParserSupportedElements?, completion: SVGCompletion?)

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
