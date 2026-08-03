//
//  SVGParseReport.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 3/8/2026.
//

/// Typed, non-fatal information produced with a successfully rendered SVG document.
public struct SVGParseReport: Equatable, Sendable {
  /// The namespace policy that admitted the document.
  public let namespaceMode: SVGNamespaceMode
  
  /// Conditions which did not prevent rendering, but are useful to a host application or editor.
  public let diagnostics: [SVGParseDiagnostic]
  
  /// Whether parsing completed with information a host may wish to surface.
  public var hasDiagnostics: Bool {
    !self.diagnostics.isEmpty
  }
  
  public init(
    namespaceMode: SVGNamespaceMode,
    diagnostics: [SVGParseDiagnostic]
  ) {
    self.namespaceMode = namespaceMode
    self.diagnostics = diagnostics
  }
}
