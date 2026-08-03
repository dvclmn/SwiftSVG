//
//  Parser+Complete.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 3/8/2026.
//

import Foundation

extension NSXMLSVGParser {
  
  /// Delivers a successful parse only after asynchronous elements have finished and the root layer
  /// has been attached to the public container layer.
  func completeParsingIfReady() {
    let isReady = self.asyncCountQueue.sync {
      self.asyncParseCount <= 0 && self.didDispatchAllElements
    }
    guard isReady else { return }
    
    guard let rootLayer = self.rootLayer, let namespaceMode = self.namespaceMode else {
      self.completeParsing(with: .failure(SVGParserError.missingRootSVGElement))
      return
    }
    
    let report = SVGParseReport(
      namespaceMode: namespaceMode,
      diagnostics: self.parseDiagnostics,
    )
    let completion = self.completionBlock
    let resultCompletion = self.resultCompletionBlock
    self.completionBlock = nil
    self.resultCompletionBlock = nil
    
    DispatchQueue.main.safeAsync {
      if rootLayer.superlayer !== self.containerLayer {
        self.containerLayer.addSublayer(rootLayer)
      }
      completion?(.success(self.containerLayer))
      resultCompletion?(.success(SVGParseResult(layer: self.containerLayer, report: report)))
    }
  }
  
  /// Delivers a terminal failure to both the established layer-only API and the richer result API.
  func completeParsing(with result: Result<SVGLayer, Error>) {
    let completion = self.completionBlock
    let resultCompletion = self.resultCompletionBlock
    self.completionBlock = nil
    self.resultCompletionBlock = nil
    
    DispatchQueue.main.safeAsync {
      completion?(result)
      switch result {
        case .success(let layer):
          guard let namespaceMode = self.namespaceMode else {
            resultCompletion?(.failure(SVGParserError.missingRootSVGElement))
            return
          }
          let report = SVGParseReport(
            namespaceMode: namespaceMode,
            diagnostics: self.parseDiagnostics,
          )
          resultCompletion?(.success(SVGParseResult(layer: layer, report: report)))
        case .failure(let error):
          resultCompletion?(.failure(error))
      }
    }
  }
}
