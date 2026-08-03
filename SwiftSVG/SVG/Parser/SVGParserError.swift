//
//  SVGParserError.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 2/8/2026.
//

import Foundation

/// An error that prevents SwiftSVG from producing a renderable document.
public enum SVGParserError: Error, Equatable, LocalizedError, Sendable {
  /// The XML document's root element was not named `<svg>`.
  case invalidRootElement(name: String, namespaceURI: String?)

  /// The XML document's `<svg>` root declares a namespace SwiftSVG does not support.
  case unsupportedRootNamespace(namespaceURI: String)
  
  /// The document did not yield a root SVG layer.
  case missingRootSVGElement
  
  public var errorDescription: String? {
    switch self {
      case .invalidRootElement(let name, let namespaceURI):
        guard name != "svg" else {
          preconditionFailure("This error shouldn't be thrown if the root element is named 'svg'.")
        }
        return if let namespaceURI {
          "Expected the document root to be `<svg>`, but found `<\(name)>` in the `\(namespaceURI)` namespace."
        } else {
          "Expected the document root to be `<svg>`, but found `<\(name)>` without a namespace."
        }
      case .unsupportedRootNamespace(let namespaceURI):
        return "The root `<svg>` element declares unsupported namespace `\(namespaceURI)`. Expected `http://www.w3.org/2000/svg`, or no namespace for compatibility mode."
        
      case .missingRootSVGElement:
        return "The document did not produce an SVG root element."
    }
  }
}
