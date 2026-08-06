//
//  Print.swift
//  SwiftSVG
//
//
//  Copyright (c) 2019 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

func print(
  _ item: @autoclosure () -> Any,
  separator: String = " ",
  terminator: String = "\n"
) {
  #if DEBUG
  Swift.print(item(), separator: separator, terminator: terminator)
  #endif
}

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

extension Dictionary where Key == String {
  public var debugString: String {
    "\(.indentString + keys.joined(separator: .indentString))"
  }
}
