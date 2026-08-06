//
//  UIView+SVG.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// A set of convenience initializers that create new `UIView` instances from SVG data
extension UIView {

  /// Convenience initializer that instantiates a new `UIView` instance with a
  /// single path `d` string. The path will be parsed synchronously.
  /// ```
  /// let view = UIView(pathString: "M20 30 L30 10 l10 10")
  /// ```
  /// - Parameter pathString: The path `d` string to parse.
  public convenience init(pathString: String) {
    self.init()
    let svgLayer = SVGLayer()
    let pathPath = UIBezierPath(pathString: pathString)
    svgLayer.path = pathPath.cgPath
    #if os(iOS) || os(tvOS)
    self.layer.addSublayer(svgLayer)
    #elseif os(OSX)
    self.nonOptionalLayer.addSublayer(svgLayer)
    #endif
  }

  /// Convenience initializer that instantiates a new `UIView` for the given SVG file in the main bundle
  /// ```
  /// let view = UIView(svgNamed: "hawaiiFlowers")
  /// ```
  /// - Parameter svgNamed: The name of the SVG resource in the main bundle with an `.svg`
  ///   extension or the name an asset in the main Asset Catalog as a Data Asset.
  /// - Parameter parser: The optional parser to use to parse the SVG file
  /// - Parameter completion: A required completion block to execute once the SVG has completed parsing.
  ///   The passed `SVGLayer` will be added to this view's sublayers before executing the completion block
  public convenience init(svgNamed: String, parser: SVGParser? = nil, completion: SVGCompletion? = nil) {

    // TODO: This is too many guards to really make any sense. Also approaching on the
    // pyramid of death Refactor this at some point to be able to work cross-platform.
    if #available(iOS 9.0, OSX 10.11, *) {

      var data: Data?
      #if os(iOS)
      if let asset = NSDataAsset(name: svgNamed) {
        data = asset.data
      }
      #elseif os(OSX)
      if let asset = NSDataAsset(name: NSDataAsset.Name(svgNamed)) {
        data = asset.data
      }
      #endif

      guard let unwrapped = data else {
        guard let svgURL = Bundle.main.url(forResource: svgNamed, withExtension: "svg") else {
          self.init()
          return
        }
        do {
          let thisData = try Data(contentsOf: svgURL)
          self.init(svgData: thisData, parser: parser, completion: completion)
        } catch {
          self.init()
          return
        }
        return
      }
      self.init(svgData: unwrapped, parser: parser, completion: completion)
    } else {
      guard let svgURL = Bundle.main.url(forResource: svgNamed, withExtension: "svg") else {
        self.init()
        return
      }
      do {
        let data = try Data(contentsOf: svgURL)
        self.init(svgData: data, parser: parser, completion: completion)
      } catch {
        self.init()
        return
      }
    }
  }

  ///Convenience initializer that instantiates a new `UIView` instance for the given SVG file at the given URL
  ///
  /// Upon completion, it will resize the layer to aspect fit this view's superview
  /// ```
  /// let view = UIView(svgURL: "hawaiiFlowers", parser: aParser) { (svgLayer) in
  ///    // Do something with the passed svgLayer
  /// }
  /// ```
  /// - Parameter svgURL: The local or remote `URL` of the SVG resource
  /// - Parameter parser: The optional parser to use to parse the SVG file
  /// - Parameter completion: A required completion block to execute once the SVG has completed parsing. The passed `SVGLayer` will be added to this view's sublayers before executing the completion block
  public convenience init(svgURL: URL, parser: SVGParser? = nil, completion: SVGCompletion? = nil) {
    do {
      let svgData = try Data(contentsOf: svgURL)
      self.init(svgData: svgData, parser: parser, completion: completion)
    } catch {
      self.init()
      Swift.print("No data at URL: \(svgURL)")
    }
  }

  /// Convenience initializer that instantiates a new `UIView` instance with the given SVG data
  ///
  /// Upon completion, it will resize the layer to aspect fit this view's superview
  /// ```
  /// let view = UIView(svgData: svgData)
  /// ```
  /// - Parameter svgData: The SVG `Data` to be parsed
  /// - Parameter parser: The optional parser to use to parse the SVG file
  /// - Parameter completion: A required completion block to execute once the SVG has completed parsing.
  ///   The passed `SVGLayer` will be added to this view's sublayers before executing the completion block
  public convenience init(svgData: Data, parser: SVGParser? = nil, completion: SVGCompletion? = nil) {
    self.init()

    CALayer(svgData: svgData, parser: parser) { [weak self] (svgLayer) in
      switch svgLayer {
        case .success(let layer):
          DispatchQueue.main.safeAsync {
            self?.nonOptionalLayer.addSublayer(layer)
          }
          completion?(.success(layer))

        case .failure(let error):
          completion?(.failure(error))
      }
    }
  }

  @available(*, deprecated, renamed: "init(svgNamed:parser:completion:)")
  public convenience init(SVGNamed: String, parser: SVGParser? = nil, completion: SVGCompletion? = nil) {
    self.init(svgNamed: SVGNamed, parser: parser, completion: completion)
  }

  @available(*, deprecated, renamed: "init(svgURL:parser:completion:)")
  public convenience init(SVGURL: URL, parser: SVGParser? = nil, completion: SVGCompletion? = nil) {
    self.init(svgURL: SVGURL, parser: parser, completion: completion)
  }

  @available(*, deprecated, renamed: "init(svgData:parser:completion:)")
  public convenience init(SVGData svgData: Data, parser: SVGParser? = nil, completion: SVGCompletion? = nil) {
    self.init(svgData: svgData, parser: parser, completion: completion)
  }

}
