//
//  CALayer+SVG.swift
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

/// A set of convenience initializers that create new `CALayer` instances from SVG data.
///
/// If you choose to use these initializers, it is assumed that you would like to exercise a
/// higher level of control. As such, you must provide a completion block and then add the
/// passed `SVGLayer` to the layer of your choosing. Use the UIView extensions if you
/// prefer the easier to use one-liner initializers.
extension CALayer {

  /// Convenience initializer that creates a new `CALayer` from a local or remote URL.
  /// You must provide a completion block and add the passed `SVGLayer to a sublayer`.
  /// - Parameter svgURL: The local or remote `URL` of the SVG resource
  /// - Parameter parser: The optional parser to use to parse the SVG file
  /// - Parameter completion: A required completion block to execute once the SVG
  ///   has completed parsing. You must add the passed `SVGLayer` to a sublayer to display it.
  @discardableResult
  public convenience init(svgURL: URL, parser: SVGParser? = nil, completion: @escaping SVGCompletion) {
    do {
      let svgData = try Data(contentsOf: svgURL)
      self.init(svgData: svgData, parser: parser, completion: completion)
    } catch {
      self.init()
    }
  }

  /// Convenience initializer that creates a new `CALayer` from SVG data.
  /// You must provide a completion block and add the passed `SVGLayer to a sublayer`.
  /// - Parameter svgData: The SVG `Data` to be parsed
  /// - Parameter parser: The optional parser to use to parse the SVG file
  /// - Parameter completion: A required completion block to execute once the SVG has
  ///   completed parsing. You must add the passed `SVGLayer` to a sublayer to display it.
  @discardableResult
  public convenience init(
    svgData: Data,
    parser: SVGParser? = nil,
    completion: @escaping SVGCompletion
  ) {
    self.init()

    /// Have cached data already, return this and exit early
    if let cached = SVGCache.default[svgData.cacheKey], let cachedCopy = cached.svgLayerCopy {
      DispatchQueue.main.safeAsync {
        self.addSublayer(cachedCopy)
      }
      completion(.success(cachedCopy))
      return
    }

    /// If nothing cached, set up new parse
    let dispatchQueue = DispatchQueue(
      label: "com.straussmade.swiftsvg",
      attributes: .concurrent
    )

    dispatchQueue.async { [weak self] in

      let parserToUse: SVGParser

      if let parser = parser {
        parserToUse = parser

      } else {
        parserToUse = NSXMLSVGParser(svgData: svgData) { (result) in

          if case .success(let layer) = result {
            DispatchQueue.global(qos: .userInitiated).async {
              SVGCache.default[svgData.cacheKey] = layer
            }

            DispatchQueue.main.safeAsync {
              self?.addSublayer(layer)
            }
          }
          completion(result)
        }
      }
      parserToUse.startParsing()
    }
  }
}

// MARK: - Deprecations
extension CALayer {
  @available(*, deprecated, renamed: "init(svgURL:parser:completion:)")
  @discardableResult
  public convenience init(SVGURL: URL, parser: SVGParser? = nil, completion: @escaping SVGCompletion) {
    self.init(svgURL: SVGURL, parser: parser, completion: completion)
  }

  @available(*, deprecated, renamed: "init(svgData:parser:completion:)")
  @discardableResult
  public convenience init(SVGData: Data, parser: SVGParser? = nil, completion: @escaping SVGCompletion) {
    self.init()
  }

}
