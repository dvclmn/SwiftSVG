//
//  String+Trim.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

import Foundation

/// A `String` extension trims whitespace from the beginning or end of the string.
extension String {

  /// Function that trims the whitespace from the beginning and end of a string.
  internal func trimWhitespace() -> String {
    return self.trimmingCharacters(in: CharacterSet.whitespaces)
  }
}
