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
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
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
