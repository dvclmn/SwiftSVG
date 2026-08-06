//
//  UIColor+Extensions.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// A struct that represents named colors as listed [here](https://www.w3.org/TR/SVGColor12/#icccolor)
struct NamedColors {

  /// Dictionary of named colors
  private let fromJSON: [String: CGColor] = {

    do {
      let colorDictionary: [String: String] = try Dictionary(jsonFile: "cssColorNames")
      return
        colorDictionary
        .compactMapValues { (hexString) -> CGColor? in
          guard let asColor = UIColor(hexString: hexString)?.cgColor else {
            return nil
          }
          return asColor
        }

    } catch {
      print("Unable to get CSS Named colours from JSON file. Error: \(error)")
      return [:]
    }
  }()

  /// Subscript to access the named color. Must be one of the officially supported
  /// values listed [here](https://www.w3.org/TR/SVGColor12/#icccolor)
  subscript(index: String) -> CGColor? {
    return self.fromJSON[index]
  }
}

extension CGColor {

  /// Lazily loaded instance of `NamedColors`
  fileprivate static var named: NamedColors = {
    return NamedColors()
  }()
}

extension UIColor {

  /// Convenience initializer that creates a new UIColor based on a 3 or 6 digit
  /// hex string, integer functional, or named string.
  /// - Parameter svgString: A hex, integer functional, or named string
  /// - SeeAlso: See officially supported color formats:
  /// [https://www.w3.org/TR/SVGColor12/#sRGBcolor](https://www.w3.org/TR/SVGColor12/#sRGBcolor)
  internal convenience init?(svgString: String) {
    if svgString.hasPrefix("#") {
      self.init(hexString: svgString)
      return
    } else if svgString.hasPrefix("rgba") {
      self.init(rgbaString: svgString)
      return
    } else if svgString.hasPrefix("rgb") {
      self.init(rgbString: svgString)
      return
    }

    self.init(cssName: svgString)
  }

  /// Convenience initializer that creates a new UIColor based on a 3, 4, 6, or 8 digit hex string.
  /// The leading `#` character is optional
  /// - Parameter hexString: A 3, 4, 6, or 8 digit hex string
  internal convenience init?(hexString: String) {

    var workingString = hexString
    if workingString.hasPrefix("#") {
      workingString = String(workingString.dropFirst())
    }
    workingString = workingString.lowercased()
    let colorArray: [CGFloat]

    if workingString.count == 3 {
      guard let asInt = UInt16(workingString, radix: 16) else {
        return nil
      }
      let red = CGFloat((asInt & 0xF00) >> 8) / 15
      let green = CGFloat((asInt & 0x0F0) >> 4) / 15
      let blue = CGFloat(asInt & 0x00F) / 15
      colorArray = [red, green, blue, 1.0]
    } else if workingString.count == 4 {
      guard let asInt = UInt16(workingString, radix: 16) else {
        return nil
      }
      let red = CGFloat((asInt & 0xF000) >> 12) / 15
      let green = CGFloat((asInt & 0x0F00) >> 8) / 15
      let blue = CGFloat((asInt & 0x00F0) >> 4) / 15
      let alpha = CGFloat(asInt & 0x000F) / 15
      colorArray = [red, green, blue, alpha]
    } else if workingString.count == 6 {
      guard let asInt = UInt32(workingString, radix: 16) else {
        return nil
      }
      let red = CGFloat((asInt & 0xFF0000) >> 16) / 255
      let green = CGFloat((asInt & 0x00FF00) >> 8) / 255
      let blue = CGFloat(asInt & 0x0000FF) / 255
      colorArray = [red, green, blue, 1.0]
    } else if workingString.count == 8 {
      guard let asInt = UInt32(workingString, radix: 16) else {
        return nil
      }
      let red = CGFloat((asInt & 0xFF000000) >> 24) / 255
      let green = CGFloat((asInt & 0x00FF0000) >> 16) / 255
      let blue = CGFloat((asInt & 0x0000FF00) >> 8) / 255
      let alpha = CGFloat(asInt & 0x000000FF) / 255
      colorArray = [red, green, blue, alpha]
    } else {
      return nil
    }
    guard colorArray.count == 4 else {
      return nil
    }
    self.init(
      red: colorArray[0],
      green: colorArray[1],
      blue: colorArray[2],
      alpha: colorArray[3]
    )
  }

  /// Convenience initializer that creates a new UIColor from a integer functional,
  /// taking the form `rgb(rrr, ggg, bbb)`
  internal convenience init(rgbString: String) {
    let valuesString = rgbString.dropFirst(4).dropLast()
    self.init(colorValuesString: valuesString)
  }

  /// Convenience initializer that creates a new UIColor from an integer functional,
  /// taking the form `rgba(rrr, ggg, bbb, <alphavalue>)`
  internal convenience init(rgbaString: String) {
    let valuesString = rgbaString.dropFirst(5).dropLast()
    self.init(colorValuesString: valuesString)
  }

  private convenience init(colorValuesString: Substring) {
    let colorsArray =
      colorValuesString
      .split(separator: ",")
      .map { (numberString) -> CGFloat in
        return CGFloat(String(numberString).trimmingCharacters(in: CharacterSet.whitespaces))!
      }
    self.init(
      red: colorsArray[0] / 255.0,
      green: colorsArray[1] / 255.0,
      blue: colorsArray[2] / 255.0,
      alpha: (colorsArray.count > 3 ? colorsArray[3] / 1.0 : 1.0)
    )
  }

  /// Convenience initializer that creates a new UIColor from a CSS3 named color
  /// - SeeAlso: See here for all the colors: [https://www.w3.org/TR/css3-color/#svg-color](https://www.w3.org/TR/css3-color/#svg-color)
  public convenience init?(cssName: String) {
    guard let namedColor = CGColor.named[cssName.lowercased()] else {
      return nil
    }
    self.init(cgColor: namedColor)
  }

}
