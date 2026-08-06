# Parsing SVG documents and reporting diagnostics

Follow an SVG document from Foundation XML callbacks to an assembled layer and typed parse report.

## Start with SVG data

Create ``NSXMLSVGParser`` from `Data` and use `resultCompletion` when the host needs both rendered output and diagnostics.

```swift
let parser = NSXMLSVGParser(
  svgData: data,
  resultCompletion: { result in
    switch result {
      case .success(let parsed):
        use(parsed.layer)
        present(parsed.report.diagnostics)
      case .failure(let error):
        present(error)
    }
  },
)

parser.startParsing()
```

``SVGCompletion`` remains available for clients that need only the completed ``SVGLayer``. ``SVGParseCompletion`` is the richer contract used above.

Equivalent URL-backed initialisers are available with either `completion` or `resultCompletion`. A URL loading failure is delivered through the selected failure callback when `startParsing()` is called.

## Foundation XML parsing

``NSXMLSVGParser`` subclasses Foundation's `XMLParser` and acts as its delegate. Namespace processing and prefix reporting are enabled, while external entity resolution is disabled.

Foundation supplies three distinct element values: the local `elementName` used for SVG dispatch, the `namespaceURI` identifying the vocabulary, and the qualified name preserving the source prefix for logging. Namespace declarations arrive through mapping callbacks and SwiftSVG tracks nested prefix scopes as stacks.

The document root selects ``SVGNamespaceMode``. The SVG namespace selects `.svg`; an absent namespace selects `.unnamespacedCompatibility` and emits ``SVGParseDiagnostic/missingSVGNamespace``. A non-SVG root element or unsupported root namespace fails with ``SVGParserError``.

## Build the layer hierarchy

SwiftSVG admits only elements in the namespace selected by the document root. It creates supported `SVGElement` implementations, applies exact-key supported attributes, and records unsupported admitted elements or attributes as renderer diagnostics.

Unsupported by SwiftSVG does not mean invalid SVG. The parser's supported-element and supported-attribute dictionaries describe implementation capability, not the SVG specification.

End-element callbacks pop completed elements from the parser stack and attach their layers to supported containers. Some elements perform asynchronous processing, so Foundation's end-document callback is not itself the public completion boundary.

## Complete once

SwiftSVG completes successfully only after Foundation has dispatched all elements, asynchronous element work has finished, the document-root layer exists, and a namespace mode exists. It then attaches the root layer to the public ``SVGLayer`` and returns one ``SVGParseResult``.

Completion handlers are consumed before delivery, preventing later parser callbacks from invoking the same handler again.

## Interpret the report

``SVGParseReport`` accompanies a successful layer and records the admitted namespace mode plus non-fatal ``SVGParseDiagnostic`` values.

Until diagnostics carry source locations, SwiftSVG records each identical typed condition once per parse. Distinct names, values, or namespace contexts remain distinct, while indistinguishable repeated callbacks do not create duplicate host rows.

Current diagnostics cover:

- a missing document-root SVG namespace;
- an invalid document-root `viewBox` that SwiftSVG ignored;
- an admitted SVG element SwiftSVG does not render;
- an attribute SwiftSVG does not apply to an admitted element;
- an element skipped because its namespace is outside the document's admitted SVG mode.

Terminal XML well-formedness failures, invalid roots, unsupported root namespaces, and missing root layers are delivered through the failure side of the completion result rather than as successful diagnostics.

Individual supported-attribute closures currently return `Void`. Value-level failures inside those closures are therefore not yet part of the structured report; adding them requires a result-bearing attribute application contract.
