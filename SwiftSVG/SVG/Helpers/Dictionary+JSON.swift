//
//  Dictionary+JSON.swift
//  SwiftSVG
//
//
//  Copyright (c) 2019 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

import Foundation

extension Dictionary where Key: Decodable, Value: Decodable {

  init(jsonFile name: String?) throws {
    print("Attempting to load json file of CSS named colours. File name: \(name, default: "Not provided")")

    guard let jsonPath = Bundle.swiftSVGResources.url(forResource: "cssColorNames", withExtension: "json") else {
      throw NamedColorsError.jsonResourceNotFound
    }

    let jsonData = try Data(contentsOf: jsonPath)
    let asDictionary = try JSONDecoder().decode([Key: Value].self, from: jsonData)
    self = asDictionary
  }

}

private extension Bundle {
  static var swiftSVGResources: Bundle {
    #if SWIFT_PACKAGE
      .module
    #else
      Bundle(for: NSXMLSVGParser.self)
    #endif
  }
}

enum NamedColorsError: Error {
  case jsonResourceNotFound
}
