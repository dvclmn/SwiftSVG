//
//  AttributeName.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 7/8/2026.
//

extension SVGRootAttributes {
  enum AttributeName {
    static let width = "width"
    static let height = "height"
    static let viewBox = "viewBox"
    static let version = "version"
    static let xmlns = "xmlns"
    static let xmlnsXLink = "xmlns:xlink"
    static let preserveAspectRatio = "preserveAspectRatio"

    static let recognised: Set<String> = [
      width, height, viewBox, version, xmlns, xmlnsXLink, preserveAspectRatio,
    ]
  }

}
