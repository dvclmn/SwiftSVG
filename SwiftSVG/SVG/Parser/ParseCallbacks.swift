//
//  ParseCallbacks.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 24/2/2026.
//

import Foundation

extension NSXMLSVGParser {
  /// Starts parsing the SVG document
  public func startParsing() {

    print(
      """
      =============================================
      Parsing SVG  |  \(Date.debug) 
      ---------------------------------------------

      """)
    self.asyncCountQueue.sync {
      self.didDispatchAllElements = false
      self.asyncParseCount = 0
    }
    self.namespaceURIStackByPrefix.removeAll()
    self.elementStack.clear()
    self.rootLayer = nil
    self.namespaceMode = nil
    self.parseDiagnostics.removeAll()
    self.didSeeDocumentRootElement = false
    self.parserFailure = nil
    self.parse()
  }

  /// Records how this document identifies its root SVG element.
  func establishNamespaceMode(elementName: String, namespaceURI: String?) {
    guard elementName == SVGRootElement.elementName else {
      self.parserFailure = .invalidRootElement(name: elementName, namespaceURI: namespaceURI)
      return
    }

    switch namespaceURI {
      case Self.svgNamespaceURI:
        self.namespaceMode = .svg
      case nil:
        self.namespaceMode = .unnamespacedCompatibility
        self.parseDiagnostics.append(.missingSVGNamespace)
      default:
        self.parserFailure = .invalidRootElement(name: elementName, namespaceURI: namespaceURI)
    }
  }

  /// Whether an element's resolved namespace belongs to the current document's admitted SVG mode.
  func shouldProcessElement(namespaceURI: String?) -> Bool {
    switch self.namespaceMode {
      case .svg:
        namespaceURI == Self.svgNamespaceURI
      case .unnamespacedCompatibility:
        namespaceURI == nil
      case nil:
        false
    }
  }

  /// Returns the namespace URI currently bound to a prefix.
  func currentNamespaceURI(forPrefix prefix: String) -> String? {
    self.namespaceURIStackByPrefix[prefix]?.last
  }

  /// Returns a currently mapped namespace URI, regardless of the prefix chosen by the document.
  func currentNamespaceURI(matching namespaceURI: String) -> String? {
    self.namespaceURIStackByPrefix.values
      .compactMap { $0.last }
      .first { $0 == namespaceURI }
  }

  /// The `XMLParserDelegate` callback that reports a namespace declaration entering scope.
  open func parser(
    _ parser: XMLParser,
    didStartMappingPrefix prefix: String,
    toURI namespaceURI: String,
  ) {
    self.namespaceURIStackByPrefix[prefix, default: []].append(namespaceURI)
  }

  /// The `XMLParserDelegate` callback that reports a namespace declaration leaving scope.
  open func parser(
    _ parser: XMLParser,
    didEndMappingPrefix prefix: String,
  ) {
    guard var namespaceURIs = self.namespaceURIStackByPrefix[prefix] else {
      return
    }

    guard !namespaceURIs.isEmpty else {
      self.namespaceURIStackByPrefix.removeValue(forKey: prefix)
      return
    }

    namespaceURIs.removeLast()
    if namespaceURIs.isEmpty {
      self.namespaceURIStackByPrefix.removeValue(forKey: prefix)
    } else {
      self.namespaceURIStackByPrefix[prefix] = namespaceURIs
    }
  }

  /// The `XMLParserDelegate` method called when the parser has started parsing
  /// an SVG element. This implementation will loop through all supported attributes
  /// and dispatch the attribute value to the given curried function.
  open func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String],
  ) {

    print(
      """
      Parsing element <\(qName ?? elementName)> at \(Date.debug)
      Namespace: \(namespaceURI, default: "nil")
      Qualified name: \(qName, default: "nil")
      Attributes: \(attributeDict.prettyPrinted())


      """)
    if !self.didSeeDocumentRootElement {
      self.didSeeDocumentRootElement = true
      self.establishNamespaceMode(elementName: elementName, namespaceURI: namespaceURI)
    }

    guard self.parserFailure == nil else {
      return
    }

    guard self.shouldProcessElement(namespaceURI: namespaceURI) else {
      print(
        "Skipping element \(qName ?? elementName) outside the admitted SVG namespace: "
          + "\(String(describing: namespaceURI))"
      )
      return
    }

    guard let elementType = self.supportedElements?.tags[elementName] else {
      print("\(elementName) is unsupported, skipping.")
      //      print(
      //        "\(elementName) is unsupported. For a complete list of supported elements, see the `allSupportedElements` variable in the `SVGParserSupportedElements` struct. Click through on the `elementName` variable name to see the SVG tag name."
      //      )
      return
    }

    let svgElement = elementType()

    if let rootElement = svgElement as? SVGRootElement {
      let rootAttributes = SVGRootAttributes(
        attributes: attributeDict,
        elementNamespaceURI: namespaceURI,
        xlinkNamespaceURI: self.currentNamespaceURI(matching: Self.xlinkNamespaceURI),
      )
      if attributeDict["viewBox"] != nil, rootAttributes.viewBox == nil {
        self.parseDiagnostics.append(.invalidViewBox)
      }
      rootElement.apply(rootAttributes)
      if self.elementStack.isEmpty {
        self.containerLayer.rootAttributes = rootAttributes
      }
    }

    if var asyncElement = svgElement as? ParsesAsynchronously {
      self.asyncCountQueue.sync {
        self.asyncParseCount += 1
        asyncElement.asyncParseManager = self
      }
    }

    for (attributeName, attributeClosure) in svgElement.supportedAttributes {

      // Match the parser's exact attribute key. Unprefixed SVG attributes remain unprefixed,
      // while namespaced attributes retain their qualified spelling such as "xlink:href".
      if let attributeValue = attributeDict[attributeName] {
        print("Processing attribute:\n\"\(attributeName)\", value: \"\(attributeValue)\"\n\n")
        attributeClosure(attributeValue)
      }
    }

    print("Adding to Stack:\n\(svgElement)")
    self.elementStack.push(svgElement)
  }

  /// The `XMLParserDelegate` method called when the parser has ended parsing an SVG element. This methods pops the last element parsed off the stack and checks if there is an enclosing container layer. Every valid SVG file is guaranteed to have at least one container layer (at a minimum, a `SVGRootElement` instance).
  ///
  /// If the parser has finished parsing a `SVGShapeElement`, it will resize the parser's `containerLayer` bounding box to fit all subpaths
  ///
  /// If the parser has finished parsing a `<svg>` element, that `SVGRootElement`'s container layer is retained for attachment at the successful completion boundary.
  open func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
  ) {

    guard self.parserFailure == nil, self.shouldProcessElement(namespaceURI: namespaceURI) else {
      return
    }

    guard let last = self.elementStack.last else {
      return
    }

    guard elementName == type(of: last).elementName else {
      return
    }

    guard let lastElement = self.elementStack.pop() else {
      return
    }

    if let rootItem = lastElement as? SVGRootElement {
      self.rootLayer = rootItem.containerLayer
      return
    }

    guard let containerElement = self.elementStack.last as? SVGContainerElement else {
      return
    }

    lastElement.didProcessElement(in: containerElement)

    if let lastShapeElement = lastElement as? SVGShapeElement {
      self.resizeContainerBoundingBox(lastShapeElement.boundingBox)
    }
  }

  /// The `XMLParserDelegate` method called when the parser has finished parsing the SVG document.
  /// All supported elements and attributes are guaranteed to be dispatched at this point, but there's no
  /// guarantee that all elements have finished parsing.
  ///
  /// - SeeAlso: `CanManageAsychronousParsing` `finishedProcessing(shapeLayer:)`
  /// - SeeAlso: `XMLParserDelegate` (`parserDidEndDocument(_:)`)[https://developer.apple.com/documentation/foundation/xmlparserdelegate/1418172-parserdidenddocument]
  public func parserDidEndDocument(_ parser: XMLParser) {

    print(
      """

      ---------------------------------------------
      Parsing Complete   |  \(Date.debug) 
      Parse Count: \(asyncParseCount)
      Root layer parsed: \(rootLayer != nil)
      =============================================
      
      """
    )

    self.asyncCountQueue.sync {
      self.didDispatchAllElements = true
    }

    if let parserFailure = self.parserFailure {
      self.completeParsing(with: .failure(parserFailure))
      return
    }

    guard self.rootLayer != nil else {
      self.completeParsing(with: .failure(SVGParserError.missingRootSVGElement))
      return
    }

    self.completeParsingIfReady()
  }

  /// The `XMLParserDelegate` method called when the parser has reached a fatal error in parsing.
  /// Parsing is stopped if an error is reached and you may want to check that your SVG file passes validation.
  /// - SeeAlso: `XMLParserDelegate` (`parser(_:parseErrorOccurred:)`)[https://developer.apple.com/documentation/foundation/xmlparserdelegate/1412379-parser]
  /// - SeeAlso: (SVG Validator)[https://validator.w3.org/]
  public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("Parse Error: \(parseError.localizedDescription)")

    self.completeParsing(with: .failure(parseError))

  }

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
