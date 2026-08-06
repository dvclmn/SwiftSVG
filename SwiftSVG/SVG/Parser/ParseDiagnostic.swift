//
//  ParseDiagnostic.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 1/8/2026.
//

/// A non-fatal condition discovered while parsing an SVG document.
public enum SVGParseDiagnostic: Hashable, Sendable {
  public enum Severity: Hashable, Sendable {
    case information
    case warning
  }

  /// The root `<svg>` element did not declare the SVG XML namespace.
  case missingSVGNamespace

  /// The root `viewBox` attribute was present but did not contain four finite values with a positive width and height.
  case invalidViewBox

  /// SwiftSVG does not currently support this otherwise-admitted SVG element.
  case unsupportedElement(name: String)

  /// SwiftSVG does not currently apply this attribute to the admitted SVG element.
  case unsupportedAttribute(elementName: String, name: String, value: String)

  /// An element belongs to a namespace outside the document's admitted SVG mode.
  case elementOutsideDocumentNamespace(name: String, namespaceURI: String?)

  /// The importance a host application should give this non-fatal condition.
  public var severity: Severity {
    switch self {
      case .missingSVGNamespace, .invalidViewBox, .unsupportedElement, .unsupportedAttribute:
        .warning
      case .elementOutsideDocumentNamespace:
        .information
    }
  }

  /// A short, user-presentable heading for this diagnostic.
  public var title: String {
    switch self {
      case .missingSVGNamespace:
        "SVG namespace missing"
      case .invalidViewBox:
        "SVG viewBox is invalid"
      case .unsupportedElement(let name):
        "Unsupported <\(name)> element"
      case .unsupportedAttribute(_, let name, _):
        "Unsupported \(name) attribute"
      case .elementOutsideDocumentNamespace(let name, _):
        "Skipped non-SVG <\(name)> element"
    }
  }

  /// Further context that a host application can present alongside ``title``.
  public var message: String {
    switch self {
      case .missingSVGNamespace:
        "Rendered in compatibility mode. Add xmlns=\"http://www.w3.org/2000/svg\" to the root <svg> element for SVG XML conformance."
      case .invalidViewBox:
        "The root viewBox must contain four finite values with a positive width and height. SwiftSVG ignored it and retained any usable root width and height."
      case .unsupportedElement(let name):
        "SwiftSVG does not currently render the <\(name)> element, so it was not applied to the layer hierarchy."
      case .unsupportedAttribute(let elementName, let name, let value):
        "SwiftSVG does not currently apply \(name)=\"\(value)\" to <\(elementName)>."
      case .elementOutsideDocumentNamespace(let name, let namespaceURI):
        if let namespaceURI {
          "SwiftSVG skipped <\(name)> because it belongs to the \(namespaceURI) namespace rather than the admitted SVG document namespace."
        } else {
          "SwiftSVG skipped <\(name)> because it has no namespace and the document admits only the SVG namespace."
        }
    }
  }
}
