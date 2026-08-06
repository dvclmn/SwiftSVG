# ``SwiftSVG``

Parse SVG XML into Core Animation layer hierarchies while preserving source-authored root geometry and typed information about non-fatal rendering conditions.

## Overview

SwiftSVG uses Foundation's `XMLParser` through ``NSXMLSVGParser``. A successful rich completion returns ``SVGParseResult``, which combines the fully assembled ``SVGLayer`` with ``SVGParseReport``. Existing clients can continue using the layer-only ``SVGCompletion`` contract.

Use the parse report when a host needs to distinguish a conforming SVG render from compatibility behaviour or from content SwiftSVG could not apply.

## Topics

### Parsing

- <doc:ParsingAndDiagnostics>
- ``NSXMLSVGParser``
- ``SVGParseResult``
- ``SVGParseReport``
- ``SVGParseDiagnostic``
- ``SVGParserError``
- ``SVGNamespaceMode``

### Rendered output

- ``SVGLayer``
- ``SVGRootAttributes``
- ``SVGLength``
