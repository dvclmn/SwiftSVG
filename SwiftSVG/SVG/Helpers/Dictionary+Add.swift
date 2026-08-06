//
//  Dictionary+Add.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

/// An extension that add the elements of one dictionary to another
extension Dictionary {

  /// An extension that add the elements of one dictionary to another
  public mutating func add(_ dictionary: [Key: Value]) {
    for (key, value) in dictionary {
      self[key] = value
    }
  }
}

