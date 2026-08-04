//
//  Parser+Namespace.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 3/8/2026.
//

import Foundation

extension NSXMLSVGParser {

  /// Records how this document identifies its root SVG element.
  func establishNamespaceMode(elementName: String, namespaceURI: String?) {
    guard elementName == SVGRootElement.elementName else {
      self.parserFailure = .invalidRootElement(name: elementName, namespaceURI: namespaceURI)
      return
    }

    switch namespaceURI {
      case Self.svgNamespaceURI:
        self.namespaceMode = .svg
      case nil:
        self.namespaceMode = .unnamespacedCompatibility
        self.parseDiagnostics.append(.missingSVGNamespace)
      case let namespaceURI?:
        self.parserFailure = .unsupportedRootNamespace(namespaceURI: namespaceURI)
    }
  }

  /// Normalises Foundation's empty-string representation of an absent XML namespace.
  func normalisedNamespaceURI(_ namespaceURI: String?) -> String? {
    guard let namespaceURI, !namespaceURI.isEmpty else {
      return nil
    }
    return namespaceURI
  }

  /// Returns the namespace URI currently bound to a prefix.
  func currentNamespaceURI(forPrefix prefix: String) -> String? {
    self.namespaceURIStackByPrefix[prefix]?.last
  }

  /// Returns a currently mapped namespace URI, regardless of the prefix chosen by the document.
  func currentNamespaceURI(matching namespaceURI: String) -> String? {
    self.namespaceURIStackByPrefix.values
      .compactMap { $0.last }
      .first { $0 == namespaceURI }
  }

}
