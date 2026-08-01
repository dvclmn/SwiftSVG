//
//  SVGLength.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 31/7/2026.
//

import Foundation

/// An authored SVG length and its unit.
///
/// The raw source is retained because not every SVG length can be resolved without layout context.
/// For example, percentages depend on the containing viewport, while absolute CSS units require a
/// conversion policy. SwiftSVG currently resolves only unitless values and pixel values locally.
public struct SVGLength: Equatable, Sendable {

  /// The unit written after the numeric component of an SVG length.
  public enum Unit: Equatable, Sendable {
    case number
    case pixels
    case percentage
    case other(String)
  }

  /// The attribute value exactly as supplied by the SVG source.
  public let rawValue: String

  /// The finite numeric component, when the source begins with a valid number.
  public let value: Double?

  /// The unit associated with ``value``.
  public let unit: Unit

  /// Creates a length while retaining its source representation.
  public init(rawValue: String) {
    self.rawValue = rawValue

    let source = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    let scanner = Scanner(string: source)
    scanner.locale = Locale(identifier: "en_US_POSIX")
    scanner.charactersToBeSkipped = nil

    guard let value = scanner.scanDouble(), value.isFinite else {
      self.value = nil
      self.unit = .other(source)
      return
    }

    let suffix = String(source[scanner.currentIndex...])
    self.value = value

    switch suffix.lowercased() {
      case "":
        self.unit = .number
      case "px":
        self.unit = .pixels
      case "%":
        self.unit = .percentage
      default:
        self.unit = .other(suffix)
    }
  }

  /// The concrete value in pixels when no external layout or conversion context is required.
  public var pixels: Double? {
    guard let value else { return nil }

    switch unit {
      case .number, .pixels:
        return value
      case .percentage, .other:
        return nil
    }
  }

}
