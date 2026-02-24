//
//  Date.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 24/2/2026.
//
import Foundation

/// Tiny helper to provide easier-to-read time stamp for debugging
extension Date {
  static var debug: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "HH:mm:ss.SSS"
    return formatter.string(from: Date())
  }
}
