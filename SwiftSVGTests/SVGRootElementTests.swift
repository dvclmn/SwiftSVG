//
//  SVGRootElementTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

import Foundation
import Testing

@Suite("SVG root attributes")
struct SVGRootElementTests {

  @Test("Root dimensions remain separate from the viewBox")
  func parsesRootDimensions() {
    let attributes = SVGRootAttributes(attributes: [
      "width": "400px",
      "height": "300",
      "viewBox": "10, 20 100\t200",
      "version": "1.1",
      "xmlns": "http://www.w3.org/2000/svg",
      "preserveAspectRatio": "xMidYMid meet",
    ])

    #expect(attributes.width == SVGLength(rawValue: "400px"))
    #expect(attributes.height == SVGLength(rawValue: "300"))
    #expect(attributes.viewportSize == CGSize(width: 400, height: 300))
    #expect(attributes.viewBox == CGRect(x: 10, y: 20, width: 100, height: 200))
    #expect(attributes.version == "1.1")
    #expect(attributes.namespace == "http://www.w3.org/2000/svg")
    #expect(attributes.preserveAspectRatio == "xMidYMid meet")
  }

  @Test(
    "Only locally resolvable lengths produce a viewport",
    arguments: ["100%", "12mm", "auto"]
  )
  func leavesContextDependentWidthUnresolved(_ width: String) {
    let attributes = SVGRootAttributes(attributes: [
      "width": width,
      "height": "200px",
    ])

    #expect(attributes.width?.rawValue == width)
    #expect(attributes.viewportSize == nil)
  }

  @Test(
    "Malformed viewBox values are not partially accepted",
    arguments: ["0 0 100 infinity", "0 0 100 0", "0 0 -100 200"]
  )
  func rejectsMalformedViewBox(_ viewBox: String) {
    let attributes = SVGRootAttributes(attributes: [
      "viewBox": viewBox,
    ])

    #expect(attributes.viewBox == nil)
  }

  @Test @MainActor
  func parserReportsInvalidViewBoxWhileRetainingUsableViewport() async throws {
    let source = """
      <svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 100 0">
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let result = try await withCheckedThrowingContinuation { continuation in
      parser.resultCompletionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(result.layer.viewBox == nil)
    #expect(result.layer.viewportSize == CGSize(width: 400, height: 300))
    #expect(result.report.diagnostics == [.invalidViewBox])
  }

  @Test @MainActor
  func nestedSVGDoesNotProduceARootViewBoxDiagnostic() async throws {
    let source = """
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <svg viewBox="0 0 50 0"></svg>
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let result = try await withCheckedThrowingContinuation { continuation in
      parser.resultCompletionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(result.report.diagnostics.isEmpty)
  }

  @Test @MainActor
  func invalidRootAndNestedViewBoxesProduceOneRootDiagnostic() async throws {
    let source = """
      <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 0">
        <svg viewBox="0 0 50 0"></svg>
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let result = try await withCheckedThrowingContinuation { continuation in
      parser.resultCompletionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(result.report.diagnostics == [.invalidViewBox])
  }

  @Test @MainActor
  func parserPublishesAttributesOnCompletedLayer() async throws {
    let source = """
      <svg width="400" height="300" viewBox="10 20 100 200" xmlns="http://www.w3.org/2000/svg">
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let layer = try await withCheckedThrowingContinuation { continuation in
      parser.completionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(layer.viewportSize == CGSize(width: 400, height: 300))
    #expect(layer.viewBox == CGRect(x: 10, y: 20, width: 100, height: 200))
    #expect(layer.sublayers?.count == 1)
    #expect(layer.sublayers?.first?.frame == layer.viewBox)
  }

  @Test @MainActor
  func parserProcessesElementNamespacesAndRootMappings() async throws {
    let source = """
      <svg:svg width="400" height="300" viewBox="0 0 400 300"
        xmlns:svg="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink">
        <svg:circle cx="200" cy="150" r="100" />
        <foreign:circle xmlns:foreign="urn:foreign" cx="200" cy="150" r="50" />
      </svg:svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let layer = try await withCheckedThrowingContinuation { continuation in
      parser.completionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(layer.rootAttributes?.namespace == "http://www.w3.org/2000/svg")
    #expect(layer.rootAttributes?.xlinkNamespace == "http://www.w3.org/1999/xlink")
    #expect(layer.sublayers?.count == 1)
  }

  @Test @MainActor
  func parserReportsNamespaceLessCompatibilityRendering() async throws {
    let source = """
      <svg width="400" height="300" viewBox="0 0 400 300">
        <circle cx="200" cy="150" r="100" />
        <foreign:circle xmlns:foreign="urn:foreign" cx="200" cy="150" r="50" />
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let result = try await withCheckedThrowingContinuation { continuation in
      parser.resultCompletionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(result.report.namespaceMode == .unnamespacedCompatibility)
    #expect(result.report.diagnostics == [
      .missingSVGNamespace,
      .elementOutsideDocumentNamespace(name: "circle", namespaceURI: "urn:foreign"),
    ])
    #expect(result.layer.rootAttributes?.namespace == nil)
    #expect(result.layer.sublayers?.count == 1)
  }

  @Test @MainActor
  func parserReportsUnsupportedElementsAndAttributes() async throws {
    let source = """
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <text>Title</text>
        <rect width="20" height="20" data-purpose="sample" />
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let result = try await withCheckedThrowingContinuation { continuation in
      parser.resultCompletionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(result.report.diagnostics == [
      .unsupportedElement(name: "text"),
      .unsupportedAttribute(
        elementName: "rect",
        name: "data-purpose",
        value: "sample",
      ),
    ])
  }

  @Test @MainActor
  func parserReportsIndistinguishableConditionsOncePerParse() async throws {
    let source = """
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <text>First</text>
        <text>Second</text>
        <rect width="20" height="20" data-purpose="sample" />
        <rect width="20" height="20" data-purpose="sample" />
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let result = try await withCheckedThrowingContinuation { continuation in
      parser.resultCompletionBlock = { result in
        continuation.resume(with: result)
      }
      parser.startParsing()
    }

    #expect(result.report.diagnostics == [
      .unsupportedElement(name: "text"),
      .unsupportedAttribute(
        elementName: "rect",
        name: "data-purpose",
        value: "sample",
      ),
    ])
  }

  @Test @MainActor
  func URLLoadingFailureReachesTheCompletionHandler() async {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("svg")
    let parser = NSXMLSVGParser(svgURL: url)

    let error: Error? = await withCheckedContinuation { continuation in
      parser.completionBlock = { result in
        switch result {
          case .success:
            continuation.resume(returning: nil)
          case .failure(let error):
            continuation.resume(returning: error)
        }
      }
      parser.startParsing()
    }

    #expect(error != nil)
  }

  @Test @MainActor
  func URLLoadingFailureReachesTheResultCompletionHandler() async {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("svg")

    let error: Error? = await withCheckedContinuation { continuation in
      let parser = NSXMLSVGParser(
        svgURL: url,
        resultCompletion: { result in
          switch result {
            case .success:
              continuation.resume(returning: nil)
            case .failure(let error):
              continuation.resume(returning: error)
          }
        },
      )
      parser.startParsing()
    }

    #expect(error != nil)
  }

  @Test @MainActor
  func parserFailsForANonSVGRootNamespace() async {
    let source = """
      <svg xmlns="urn:foreign" viewBox="0 0 400 300">
        <circle cx="200" cy="150" r="100" />
      </svg>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let error: Error? = await withCheckedContinuation { continuation in
      parser.resultCompletionBlock = { result in
        switch result {
          case .success:
            continuation.resume(returning: nil)
          case .failure(let error):
            continuation.resume(returning: error)
        }
      }
      parser.startParsing()
    }

    #expect(
      (error as? SVGParserError)
        == .unsupportedRootNamespace(namespaceURI: "urn:foreign")
    )
  }

  @Test @MainActor
  func parserFailsForANonSVGRootElement() async {
    let source = """
      <document xmlns="http://www.w3.org/2000/svg">
      </document>
      """
    let parser = NSXMLSVGParser(svgData: Data(source.utf8))

    let error: Error? = await withCheckedContinuation { continuation in
      parser.resultCompletionBlock = { result in
        switch result {
          case .success:
            continuation.resume(returning: nil)
          case .failure(let error):
            continuation.resume(returning: error)
        }
      }
      parser.startParsing()
    }

    #expect(
      (error as? SVGParserError)
        == .invalidRootElement(name: "document", namespaceURI: "http://www.w3.org/2000/svg")
    )
  }

  @Test("SVG parser errors describe the failed root condition")
  func describesRootFailures() {
    #expect(
      SVGParserError.invalidRootElement(name: "document", namespaceURI: nil).errorDescription
        == "Expected the document root to be `<svg>`, but found `<document>` without a namespace."
    )
    #expect(
      SVGParserError.unsupportedRootNamespace(namespaceURI: "urn:foreign").errorDescription
        == "The root `<svg>` element declares unsupported namespace `urn:foreign`. Expected `http://www.w3.org/2000/svg`, or no namespace for compatibility mode."
    )
  }
}
