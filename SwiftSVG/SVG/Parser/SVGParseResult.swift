//
//  SVGParseResult.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 3/8/2026.
//

import Foundation

/// A callback invoked when SVG parsing completes with both the rendered layer and parse report.
public typealias SVGParseCompletion = (Result<SVGParseResult, Error>) -> Void

/// A callback invoked when SVG parsing and layer assembly succeeds or fails.
public typealias SVGCompletion = (Result<SVGLayer, Error>) -> Void

@available(*, deprecated, renamed: "SVGCompletion")
public typealias SVGResult = SVGCompletion

/// The fully assembled renderer layer and its typed parse report.
public struct SVGParseResult {
  /// The layer hierarchy that SwiftSVG produced.
  public let layer: SVGLayer

  /// Information about how that layer hierarchy was produced.
  public let report: SVGParseReport

  public init(layer: SVGLayer, report: SVGParseReport) {
    self.layer = layer
    self.report = report
  }
}
