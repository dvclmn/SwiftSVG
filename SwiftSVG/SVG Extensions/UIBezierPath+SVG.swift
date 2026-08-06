//
//  UIBezierPath+SVG.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// Convenience initializer that can parse a single path string and returns a `UIBezierPath`
extension UIBezierPath {

  /// Parses a single path string. Parses synchronously.
  /// - Parameter pathString: The path `d` string to parse.
  public convenience init(pathString: String) {
    let singlePath = SVGPath(singlePathString: pathString)
    guard let cgPath = singlePath.svgLayer.path else {
      self.init()
      return
    }
    #if os(iOS) || os(tvOS)
    self.init(cgPath: cgPath)
    #elseif os(OSX)
    self.init()
    #endif
  }

  @available(
    *, deprecated,
    message:
      "This method is deprecated. If you want to parse a single path, instantiate a new instance of SVGPath using the SVGPath(singlePathString:) initializer and pass the path string."
  )
  public class func pathWithSVGURL(_ SVGURL: URL) -> UIBezierPath? {
    assert(false, "This method is deprecated")
    return nil
  }

}
