//
//  SVGNamespaceMode.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 3/8/2026.
//

/// The namespace policy used while parsing the SVG document.
public enum SVGNamespaceMode: Equatable, Sendable {
  /// The document declared the SVG XML namespace and was
  /// parsed as a conforming SVG XML document.
  ///
  ///  E.g. namespace: `xmlns="http://www.w3.org/2000/svg"`
  case svg

  /// The document omitted the SVG XML namespace and was
  /// accepted using SwiftSVG's compatibility path.
  case unnamespacedCompatibility
}
