//
//  SVGRootAttributes.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 31/7/2026.
//

import CoreGraphics
import Foundation

/// Source-authored attributes from the document's root `<svg>` element.
///
/// This value deliberately keeps the SVG user-coordinate rectangle (``viewBox``) separate from
/// the intended layout size (``viewportSize``). Renderer layer geometry is an implementation detail
/// and should not be used as a substitute for either value.
public struct SVGRootAttributes: Equatable, Sendable {

  /// Root attributes consumed as document metadata rather than renderer attributes.
  static let recognisedAttributeNames: Set<String> = [
    "width",
    "height",
    "viewBox",
    "version",
    "xmlns",
    "xmlns:xlink",
    "preserveAspectRatio",
  ]

  /// The root `width` attribute, including its authored unit.
  public let width: SVGLength?

  /// The root `height` attribute, including its authored unit.
  public let height: SVGLength?

  /// The user-coordinate rectangle parsed from `viewBox`.
  public let viewBox: CGRect?

  /// The root SVG `version` attribute.
  public let version: String?

  /// The resolved namespace URI of the root element.
  public let namespace: String?

  /// The XLink namespace URI declared in scope at the root element.
  public let xlinkNamespace: String?

  /// The raw root `preserveAspectRatio` attribute.
  public let preserveAspectRatio: String?

  /// Creates an explicit root-attribute value.
  public init(
    width: SVGLength? = nil,
    height: SVGLength? = nil,
    viewBox: CGRect? = nil,
    version: String? = nil,
    namespace: String? = nil,
    xlinkNamespace: String? = nil,
    preserveAspectRatio: String? = nil,
  ) {
    self.width = width
    self.height = height
    self.viewBox = viewBox
    self.version = version
    self.namespace = namespace
    self.xlinkNamespace = xlinkNamespace
    self.preserveAspectRatio = preserveAspectRatio
  }

  /// Creates root attributes from a raw root-element attribute dictionary.
  ///
  /// This form is useful when namespace declarations are still present in the dictionary. The
  /// namespace-aware parser path uses the initialiser that accepts `elementNamespaceURI`.
  public init(attributes: [String: String]) {
    self.init(
      width: attributes["width"].map(SVGLength.init(rawValue:)),
      height: attributes["height"].map(SVGLength.init(rawValue:)),
      viewBox: attributes["viewBox"].flatMap(Self.parseViewBox),
      version: attributes["version"],
      namespace: attributes["xmlns"],
      xlinkNamespace: attributes["xmlns:xlink"],
      preserveAspectRatio: attributes["preserveAspectRatio"],
    )
  }

  /// Creates root attributes from `XMLParser` values when namespace processing is enabled.
  ///
  /// `XMLParser` reports namespace declarations through its namespace-mapping callbacks rather
  /// than retaining `xmlns` declarations in `attributeDict`. The direct dictionary initialiser
  /// remains available for callers that already have the authored attributes.
  init(
    attributes: [String: String],
    elementNamespaceURI: String?,
    xlinkNamespaceURI: String? = nil,
  ) {
    self.init(
      width: attributes["width"].map(SVGLength.init(rawValue:)),
      height: attributes["height"].map(SVGLength.init(rawValue:)),
      viewBox: attributes["viewBox"].flatMap(Self.parseViewBox),
      version: attributes["version"],
      namespace: elementNamespaceURI ?? attributes["xmlns"],
      xlinkNamespace: xlinkNamespaceURI ?? attributes["xmlns:xlink"],
      preserveAspectRatio: attributes["preserveAspectRatio"],
    )
  }

  /// The authored viewport size when both dimensions are locally resolvable.
  ///
  /// Unitless and `px` dimensions resolve directly. Percentages and other CSS units remain
  /// unresolved because they require an external layout or conversion context.
  public var viewportSize: CGSize? {
    guard
      let width = width?.pixels,
      let height = height?.pixels
    else {
      return nil
    }

    return CGSize(width: width, height: height)
  }

  private static func parseViewBox(_ source: String) -> CGRect? {
    let components = source.split { character in
      character == "," || character.isWhitespace
    }

    guard
      components.count == 4,
      let minX = Double(components[0]),
      let minY = Double(components[1]),
      let width = Double(components[2]),
      let height = Double(components[3]),
      minX.isFinite,
      minY.isFinite,
      width.isFinite,
      height.isFinite,
      width > 0,
      height > 0
    else {
      return nil
    }

    return CGRect(x: minX, y: minY, width: width, height: height)
  }
}
