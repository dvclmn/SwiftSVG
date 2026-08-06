//
//  String+Subscript.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension String {

  /// Helper function that creates a new String from a given integer range
  public subscript(integerRange: Range<Int>) -> String {
    get {
      let start = self.index(self.startIndex, offsetBy: integerRange.lowerBound)
      let end = self.index(self.startIndex, offsetBy: integerRange.upperBound)
      return String(self[start..<end])
    }
  }
}
