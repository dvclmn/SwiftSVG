//
//  Dictionary+Print.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 24/2/2026.
//

import Foundation

extension Dictionary {

  public func prettyPrinted(
    valueMaxLength: Int? = 30,
    aligned: Bool = true,
  ) -> String {
    guard !isEmpty else { return "[:]" }

    let pairs = map {
      let valueStr = String(describing: $1).prefix(valueMaxLength ?? Int.max)
      return (key: "\"\($0)\":", value: "\"\(valueStr)\"")
    }
    .sorted { $0.key < $1.key }

    let lines: [String]

    if aligned {
      let maxKeyLength = pairs.map(\.key.count).max() ?? 0
      lines = pairs.map { key, value in
        let paddingLength = maxKeyLength - key.count + 1
        let padding = String(repeating: " ", count: paddingLength)
        return "    \(key)\(padding)\(value)"
      }
    } else {
      lines = pairs.map { key, value in
        "    \(key) \(value)"
      }
    }
    return "[\n\(lines.joined(separator: "\n"))\n]"
  }
}


extension String {
  static var indentString: String {
    "\n    - "
  }
}
