//
//  DelaysApplyingAttributes.swift
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

/// A protocol that describes an instance that will delay processing attributes, usually until in
///  `didProcessElement(in container: SVGContainerElement?)` because either
///  all path information isn't available or when the element needs to apply an attribute to all subelements.
public protocol DelaysApplyingAttributes {

  /// The attributes to apply to all sublayers after all subelements have been processed.
  /// - parameter Key: The name of an element's attribute such as `d`, `fill`, and `rx`.
  /// - parameter Value: The string value of the attribute passed from the parser, such as `"#ff00ee"`
  var delayedAttributes: [String: String] { get set }
}

/// An extension that applies any saved and supported attributes
extension DelaysApplyingAttributes where Self: SVGElement {

  /// Applies any saved and supported attributes
  public mutating func applyDelayedAttributes() {
    for (attribute, value) in self.delayedAttributes {
      self.applySupportedAttribute(named: attribute, value: value)
    }

    self.supportedAttributes.removeAll()
    self.delayedAttributes.removeAll()
  }
}
