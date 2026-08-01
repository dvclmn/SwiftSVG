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

  /// The root `width` attribute, including its authored unit.
  public let width: SVGLength?

  /// The root `height` attribute, including its authored unit.
  public let height: SVGLength?

  /// The user-coordinate rectangle parsed from `viewBox`.
  public let viewBox: CGRect?

  /// The root SVG `version` attribute.
  public let version: String?

  /// The root `xmlns` attribute.
  public let namespace: String?

  /// The root `xmlns:xlink` attribute.
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

  /// Creates root attributes from the dictionary supplied by `XMLParser`.
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
      height.isFinite
    else {
      return nil
    }

    return CGRect(x: minX, y: minY, width: width, height: height)
  }
}
