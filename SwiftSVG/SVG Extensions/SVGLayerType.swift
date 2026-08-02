//
//  SVGLayerType.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 2/8/2026.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// A protocol that describes an instance that can store bounding box information
public protocol SVGLayerType {
  var boundingBox: CGRect { get }
}

extension SVGLayerType where Self: CALayer {

  /// Scales a layer to aspect fit the given size.
  /// - Parameter rect: The `CGRect` to fit into
  // - TODO: Should eventually support different content modes
  @discardableResult
  public func resizeToFit(_ rect: CGRect) -> Self {

    let boundingBoxAspectRatio = self.boundingBox.width / self.boundingBox.height
    let viewAspectRatio = rect.width / rect.height

    let scaleFactor: CGFloat
    if boundingBoxAspectRatio > viewAspectRatio {

      /// Width is limiting factor
      scaleFactor = rect.width / self.boundingBox.width
    } else {

      /// Height is limiting factor
      scaleFactor = rect.height / self.boundingBox.height
    }
    let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)

    DispatchQueue.main.safeAsync {
      self.setAffineTransform(scaleTransform)
    }
    return self
  }
}
