//
//  SVGView.swift
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

// TODO: Removing IBDesignable support for now seeing there
// is a bug with using IBDesignables from a framework
//
// References:
// https://openradar.appspot.com/23114017
// https://github.com/Carthage/Carthage/issues/335
// https://stackoverflow.com/questions/29933691/ibdesignable-from-external-framework

//@IBDesignable

/// A `UIView` subclass that can be used in Interface Builder where you can set the @IBInspectable propert `SVGName` in the side panel. Use the UIView extensions if you want to creates SVG views programmatically.
open class SVGView: UIView {

  /// The name of the SVG file in the main bundle
  @IBInspectable
  open var svgName: String? {
    didSet {
      guard let thisName = self.svgName else {
        return
      }

      #if TARGET_INTERFACE_BUILDER
      let bundle = Bundle(for: type(of: self))
      #else
      let bundle = Bundle.main
      #endif

      if let url = bundle.url(forResource: thisName, withExtension: "svg") {
        CALayer(svgURL: url) { [weak self] (result) in
          guard let layer = try? result.get() else {
            return
          }
          self?.nonOptionalLayer.addSublayer(layer)

        }
      } else if #available(iOS 9.0, tvOS 9.0, OSX 10.11, *) {
        #if os(iOS) || os(tvOS)
        guard let asset = NSDataAsset(name: thisName, bundle: bundle) else {
          return
        }
        #elseif os(OSX)
        guard let asset = NSDataAsset(name: NSDataAsset.Name(thisName as NSString), bundle: bundle) else {
          return
        }
        #endif
        let data = asset.data
        CALayer(svgData: data) { [weak self] (result) in
          guard let layer = try? result.get() else {
            return
          }
          self?.nonOptionalLayer.addSublayer(layer)
          //                    self?.nonOptionalLayer.addSublayer(result)
        }
      }

    }
  }

  @available(*, deprecated, renamed: "svgName")
  open var SVGName: String?
}
