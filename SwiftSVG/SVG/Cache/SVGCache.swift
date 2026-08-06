//
//  SVGCache.swift
//  SwiftSVG
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

/// A minimal in-memory cache class for caching `SVGLayer`s. The `default` singleton is the default cache used and you can optionally create your own static singleton through an extension.
open class SVGCache {

  /// A singleton object that is the default store for `SVGlayer`s
  public static let `default` = SVGCache()

  public let memoryCache = NSCache<NSString, SVGLayer>()

  /// Subscript to get or set the `SVGLayer` in this cache
  public subscript(key: String) -> SVGLayer? {
    get {
      return self.memoryCache.object(forKey: key as NSString)
    }
    set {
      guard let newValue = newValue else {
        return
      }
      self.memoryCache.setObject(newValue, forKey: key as NSString)
    }
  }

  /// Removes the value from the cache
  public func removeObject(key: String) {
    self.memoryCache.removeObject(forKey: key as NSString)
  }
}
