//
//  SVGRootElementTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
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
    #expect(result.report.diagnostics == [.missingSVGNamespace])
    #expect(result.layer.rootAttributes?.namespace == nil)
    #expect(result.layer.sublayers?.count == 1)
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
        == .invalidRootElement(name: "svg", namespaceURI: "urn:foreign")
    )
  }
}
