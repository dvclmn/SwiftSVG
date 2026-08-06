//
//  Dictionary+Add.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
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

