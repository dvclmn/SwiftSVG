//
//  Parser+Complete.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 3/8/2026.
//

import Foundation

private typealias ParserCompletionHandlers = (
  layer: SVGCompletion?,
  result: SVGParseCompletion?
)

extension NSXMLSVGParser {

  /// Delivers a successful parse only after asynchronous elements have finished and the root layer
  /// has been attached to the public container layer.
  func completeParsingIfReady() {
    let isReady = self.asyncCountQueue.sync {
      self.asyncParseCount <= 0 && self.didDispatchAllElements
    }
    guard isReady else { return }

    guard let rootLayer = self.rootLayer, let report = self.parseReport else {
      self.completeParsing(with: .failure(SVGParserError.missingRootSVGElement))
      return
    }

    let handlers = self.takeCompletionHandlers()

    DispatchQueue.main.safeAsync {
      if rootLayer.superlayer !== self.containerLayer {
        self.containerLayer.addSublayer(rootLayer)
      }
      handlers.layer?(.success(self.containerLayer))
      handlers.result?(.success(SVGParseResult(layer: self.containerLayer, report: report)))
    }
  }

  /// Delivers a terminal failure to both the established layer-only API and the richer result API.
  func completeParsing(with result: Result<SVGLayer, Error>) {
    let handlers = self.takeCompletionHandlers()
    let parseResult = result.flatMap { layer -> Result<SVGParseResult, Error> in
      guard let report = self.parseReport else {
        return .failure(SVGParserError.missingRootSVGElement)
      }

      return .success(SVGParseResult(layer: layer, report: report))
    }

    DispatchQueue.main.safeAsync {
      handlers.layer?(result)
      handlers.result?(parseResult)
    }
  }

  private var parseReport: SVGParseReport? {
    guard let namespaceMode = self.namespaceMode else { return nil }

    return SVGParseReport(
      namespaceMode: namespaceMode,
      diagnostics: self.parseDiagnostics,
    )
  }

  private func takeCompletionHandlers() -> ParserCompletionHandlers {
    let handlers = (
      layer: self.completionBlock,
      result: self.resultCompletionBlock,
    )
    self.completionBlock = nil
    self.resultCompletionBlock = nil

    return handlers
  }
}
