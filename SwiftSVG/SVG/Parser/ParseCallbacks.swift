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

  /// Whether an element's resolved namespace belongs to the current
  /// document's admitted SVG mode.
  func shouldProcessElement(namespaceURI: String?) -> Bool {
    return switch self.namespaceMode {
      case .svg: namespaceURI == Self.svgNamespaceURI
      case .unnamespacedCompatibility: namespaceURI == nil
      case nil: false
    }
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
  /// an SVG element. This implementation dispatches supported attributes to their
  /// curried functions and prints any attributes that SwiftSVG does not consume.
  open func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String],
  ) {
    let namespaceURI = self.normalisedNamespaceURI(namespaceURI)
    let elementDisplayName = qName ?? elementName

    self.logStartedElement(
      elementDisplayName,
      namespaceURI: namespaceURI,
      qualifiedName: qName,
      attributes: attributeDict,
    )
    self.establishNamespaceModeIfNeeded(
      elementName: elementName,
      namespaceURI: namespaceURI,
    )

    guard self.parserFailure == nil else { return }

    guard self.shouldProcessElement(namespaceURI: namespaceURI) else {
      self.logSkippedElement(elementDisplayName, namespaceURI: namespaceURI)
      return
    }

    guard let makeElement = self.supportedElements?.tags[elementName] else {
      print("\(elementName) is unsupported, skipping.")
      return
    }

    let svgElement = makeElement()

    let rootElement = svgElement as? SVGRootElement

    if let rootElement {
      self.processRootAttributes(
        attributeDict,
        for: rootElement,
        namespaceURI: namespaceURI,
      )
    }

    self.registerAsynchronousParsingIfNeeded(for: svgElement)
    self.applySupportedAttributes(attributeDict, to: svgElement)
    self.reportUnsupportedAttributes(
      attributeDict,
      for: svgElement,
      elementDisplayName: elementDisplayName,
      isRootElement: rootElement != nil,
    )
    self.logAddedToStack(svgElement)
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
    let namespaceURI = self.normalisedNamespaceURI(namespaceURI)

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

}

// MARK: - Helpers
extension NSXMLSVGParser {

  fileprivate func establishNamespaceModeIfNeeded(
    elementName: String,
    namespaceURI: String?,
  ) {
    guard !self.didSeeDocumentRootElement else { return }

    self.didSeeDocumentRootElement = true
    self.establishNamespaceMode(
      elementName: elementName,
      namespaceURI: namespaceURI,
    )
  }

  fileprivate func processRootAttributes(
    _ attributes: [String: String],
    for rootElement: SVGRootElement,
    namespaceURI: String?,
  ) {
    let rootAttributes = SVGRootAttributes(
      attributes: attributes,
      elementNamespaceURI: namespaceURI,
      xlinkNamespaceURI: self.currentNamespaceURI(matching: Self.xlinkNamespaceURI),
    )

    if attributes["viewBox"] != nil, rootAttributes.viewBox == nil {
      self.parseDiagnostics.append(.invalidViewBox)
    }

    rootElement.apply(rootAttributes)

    guard self.elementStack.isEmpty else { return }
    self.containerLayer.rootAttributes = rootAttributes
  }

  fileprivate func registerAsynchronousParsingIfNeeded(for element: SVGElement) {
    guard var asynchronousElement = element as? ParsesAsynchronously else { return }

    self.asyncCountQueue.sync {
      self.asyncParseCount += 1
      asynchronousElement.asyncParseManager = self
    }
  }

  fileprivate func applySupportedAttributes(
    _ attributes: [String: String],
    to element: SVGElement,
  ) {
    for attributeName in element.supportedAttributes.keys {
      // Match the parser's exact attribute key. Unprefixed SVG attributes remain unprefixed,
      // while namespaced attributes retain their qualified spelling such as "xlink:href".
      guard let attributeValue = attributes[attributeName] else { continue }

      self.logProcessedAttribute(attributeName, value: attributeValue)
      element.applySupportedAttribute(named: attributeName, value: attributeValue)
    }
  }

  fileprivate func reportUnsupportedAttributes(
    _ attributes: [String: String],
    for element: SVGElement,
    elementDisplayName: String,
    isRootElement: Bool,
  ) {
    var consumedAttributeNames = Set(element.supportedAttributes.keys)
    if isRootElement {
      consumedAttributeNames.formUnion(SVGRootAttributes.recognisedAttributeNames)
    }

    for (attributeName, attributeValue) in attributes.sorted(by: { $0.key < $1.key })
    where !consumedAttributeNames.contains(attributeName) {
      print(
        "Skipping attribute on <\(elementDisplayName)>: \"\(attributeName)\" = \"\(attributeValue)\" "
          + "(unsupported by SwiftSVG; not applied)."
      )
    }
  }
}

// MARK: - Console Logging
extension NSXMLSVGParser {

  func logStartedElement(
    _ elementDisplayName: String,
    namespaceURI: String?,
    qualifiedName: String?,
    attributes: [String: String],
  ) {
    print(
      """

      ----
      Parsing element <\(elementDisplayName)> at \(Date.debug)
      Namespace: \(namespaceURI, default: "nil")
      Qualified name: \(qualifiedName, default: "nil")
      Attributes: \(attributes.prettyPrinted())


      """)
  }

  func logSkippedElement(_ elementDisplayName: String, namespaceURI: String?) {
    print(
      "Skipping element \(elementDisplayName) outside the admitted SVG namespace: "
        + "\(String(describing: namespaceURI))"
    )
  }

  func logProcessedAttribute(_ attributeName: String, value: String) {
    print(
      """
      Processing attribute:
      \"\(attributeName)\", value: \"\(value)\"

      """
    )
  }

  func logAddedToStack(_ element: SVGElement) {
    print(
      """
      Adding to Stack:
      \(element)
      ----
      """
    )
  }
}
