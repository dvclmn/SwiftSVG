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
    }
    self.parse()
  }

  /// The `XMLParserDelegate` method called when the parser has started parsing an SVG element. This implementation will loop through all supported attributes and dispatch the attribute value to the given curried function.
  open func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String]
  ) {

    print(
      """

      Parsing element \"\(elementName)\" at \(Date.debug)
      Namespace: \(String(describing: namespaceURI))
      Qualified name: \(String(describing: qName))
      Attributes: \(attributeDict.prettyPrinted())


      """)
    guard let elementType = self.supportedElements?.tags[elementName] else {
      print("\(elementName) is unsupported, skipping.")
      //      print(
      //        "\(elementName) is unsupported. For a complete list of supported elements, see the `allSupportedElements` variable in the `SVGParserSupportedElements` struct. Click through on the `elementName` variable name to see the SVG tag name."
      //      )
      return
    }

    let svgElement = elementType()

    if var asyncElement = svgElement as? ParsesAsynchronously {
      self.asyncCountQueue.sync {
        self.asyncParseCount += 1
        asyncElement.asyncParseManager = self
      }
    }

    for (attributeName, attributeClosure) in svgElement.supportedAttributes {

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
  /// If the parser has finished parsing a `<svg>` element, that `SVGRootElement`'s container layer is added to this parser's `containerLayer`.
  open func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?
  ) {

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
      DispatchQueue.main.safeAsync {
        self.containerLayer.addSublayer(rootItem.containerLayer)
      }
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
      Sublayer count: \(containerLayer.sublayers?.count, default: "nil")
      =============================================
      """)

    self.asyncCountQueue.sync {
      self.didDispatchAllElements = true
    }
    if self.asyncParseCount <= 0 {
      DispatchQueue.main.safeAsync {
        self.completionBlock?(.success(self.containerLayer))
        self.completionBlock = nil
      }
    }
  }

  /// The `XMLParserDelegate` method called when the parser has reached a fatal error in parsing.
  /// Parsing is stopped if an error is reached and you may want to check that your SVG file passes validation.
  /// - SeeAlso: `XMLParserDelegate` (`parser(_:parseErrorOccurred:)`)[https://developer.apple.com/documentation/foundation/xmlparserdelegate/1412379-parser]
  /// - SeeAlso: (SVG Validator)[https://validator.w3.org/]
  public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("Parse Error: \(parseError.localizedDescription)")

    let code = (parseError as NSError).code
    switch code {
      case 76:
        print("Invalid XML: \(SVGParserError.invalidSVG)")
      default:
        print("Some other kind of Error: \(parseError)")
        break
    }
    DispatchQueue.main.safeAsync {
      self.completionBlock?(.failure(parseError))
      self.completionBlock = nil
    }

  }

}
