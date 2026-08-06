//
//  Stylable.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

import Foundation

private struct StylableConstants {
  static let attributesRegex = "(((\\w+)-?(\\w*)?):?([ #\\w]*\\.?\\w+))"
}

/// A protocol that describes instances whose attributes that can be set vis a css style string.
/// A default implementation is supplied that parses the style string and applies the attributes
/// using the `SVGelement`'s `supportedAttributes`.
public protocol Stylable {}

extension Stylable where Self: SVGElement {
  /// The curried function to be used for the `SVGElement`'s default implementation.
  /// This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  /// - parameter Key: The SVG string value of the attribute
  /// - parameter Value: A curried function to use to implement the SVG attribute
  var styleAttributes: SVGAttributes {
    return [
      "style": self.style
    ]
  }
}

extension Stylable where Self: SVGGroup {
  /// The curried function to be used for the `SVGElement`'s default implementation.
  /// This dictionary is meant to be used in the `SVGParserSupportedElements` instance
  /// - parameter Key: The SVG string value of the attribute
  /// - parameter Value: A curried function to use to implement the SVG attribute
  var styleAttributes: SVGAttributes {
    return [
      "style": unown(self, SVGGroup.style)
    ]
  }
}

/// Default implementation for the style attribute on `SVGElement`s
extension Stylable where Self: SVGElement {

  /// Parses and applies the css-style `style` string to this `SVGElement`'s `SVGLayer`
  func style(_ styleString: String) {

    do {
      let regex = try NSRegularExpression(
        pattern: StylableConstants.attributesRegex, options: .caseInsensitive)
      let matches = regex.matches(
        in: styleString, options: NSRegularExpression.MatchingOptions(rawValue: 0),
        range: NSMakeRange(0, styleString.utf8.count))

      matches.forEach({ (thisMatch) in
        let nameRange = thisMatch.range(at: 2)
        let valueRange = thisMatch.range(at: 5)
        let styleName = styleString[nameRange.location..<nameRange.location + nameRange.length]
        let valueString = styleString[valueRange.location..<valueRange.location + valueRange.length]
          .trimWhitespace()

        guard self.applySupportedAttribute(named: styleName, value: valueString) else {
          print("Couldn't set: \(styleName)")
          return
        }
      })

    } catch {
      print("Couldn't parse style string: \(styleString)")
    }
  }
}
