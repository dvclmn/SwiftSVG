//
//  SVGContainerElement.swift
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

/// A protocol that describes an instance that can store SVG sublayers
/// and can apply a single attribute to all sublayers.
public protocol SVGContainerElement: SVGElement, DelaysApplyingAttributes, Fillable, Strokable, Transformable,
  Stylable, Identifiable
{

  /// The layer that stores all the SVG sublayers
  var containerLayer: CALayer { get set }
}
