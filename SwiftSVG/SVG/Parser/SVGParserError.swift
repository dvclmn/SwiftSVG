//
//  SVGParserError.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 2/8/2026.
//

import Foundation

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
          "Expected an SVG root element, but found `<\(name)>` in the \(namespaceURI) namespace."
        } else {
          "Expected an SVG root element, but found `<\(name)>` without a namespace."
        }
      case .missingRootSVGElement:
        "The document did not produce an SVG root element."
    }
  }
}
