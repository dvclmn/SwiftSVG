//
//  ParseDiagnostic.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 1/8/2026.
//

/// A non-fatal condition discovered while parsing an SVG document.
public enum SVGParseDiagnostic: Hashable, Sendable {
  /// The root `<svg>` element did not declare the SVG XML namespace.
  case missingSVGNamespace

  /// The root `viewBox` attribute was present but did not contain four finite values with a positive width and height.
  case invalidViewBox

  /// A short, user-presentable heading for this diagnostic.
  public var title: String {
    switch self {
      case .missingSVGNamespace:
        "SVG namespace missing"
      case .invalidViewBox:
        "SVG viewBox is invalid"
    }
  }

  /// Further context that a host application can present alongside ``title``.
  public var message: String {
    switch self {
      case .missingSVGNamespace:
        "Rendered in compatibility mode. Add xmlns=\"http://www.w3.org/2000/svg\" to the root <svg> element for SVG XML conformance."
      case .invalidViewBox:
        "The root viewBox must contain four finite values with a positive width and height. SwiftSVG ignored it and retained any usable root width and height."
    }
  }
}
