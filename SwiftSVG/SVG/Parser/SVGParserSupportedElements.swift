//
//  SVGParserConfiguration.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import Foundation

/// A struct that lists all the supported elements and attributes for a parser
public struct SVGParserSupportedElements {
    
    /// Typealias that serves as a placeholder for a closure that returns a new `SVGElement` instance
    public typealias ElementGenerator = () -> SVGElement
    
    /// A dictionary of all the supported elements and attributes for a given parser.
    /// - Parameter Key: A local SVG element name, such as `circle` or `path`.
    /// - Parameter Value: A curried function to use to handle the particular attribute
    public let tags: [String : ElementGenerator]
    
    /// Initializer to create your own set of supported tags
    /// - Parameter tags: Dictionary of SVG tag name keys and a closure values return an `SVGElement`
    public init(tags: [String : ElementGenerator]) {
        self.tags = tags
    }
    
    /// A configuration that will only parse `<path>` elements and the `d` and `fill attributes`. Use this configuration if you know you will only be parsing `<path>` elements with fill colors
    public static var barebones: SVGParserSupportedElements {
        
        let supportedElements: [String : ElementGenerator] = [
            SVGPath.elementName: {
                let returnElement = SVGPath()
                returnElement.supportedAttributes = [
                    "d": unown(returnElement, SVGPath.parseD),
                    "fill": unown(returnElement, SVGPath.fill)
                ]
                return returnElement
            },
            SVGRootElement.elementName: {
                return SVGRootElement()
            }
        ]
        return SVGParserSupportedElements(tags: supportedElements)
    }
    
    /// A configuration that is the full set of elements and attributes that SwiftSVG supports. This is the default configuration for the `NSXMLSVGParser`.
    public static var allSupportedElements: SVGParserSupportedElements {
        let supportedElements: [String : ElementGenerator] = [
            SVGCircle.elementName: {
                var returnElement = SVGCircle()
                returnElement.supportedAttributes = [
                    "cx": unown(returnElement, SVGCircle.xCenter),
                    "cy": unown(returnElement, SVGCircle.yCenter),
                    "r": unown(returnElement, SVGCircle.radius),
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGEllipse.elementName: {
                var returnElement = SVGEllipse()
                returnElement.supportedAttributes = [
                  "cx": unown(returnElement, SVGEllipse.xCenter),
                  "cy": unown(returnElement, SVGEllipse.yCenter),
                  "rx": unown(returnElement, SVGEllipse.xRadius),
                  "ry": unown(returnElement, SVGEllipse.yRadius),
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGGroup.elementName: {
                let returnElement = SVGGroup()
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGLine.elementName: {
                var returnElement = SVGLine()
                returnElement.supportedAttributes = [
                    "x1": unown(returnElement, SVGLine.x1),
                    "x2": unown(returnElement, SVGLine.x2),
                    "y1": unown(returnElement, SVGLine.y1),
                    "y2": unown(returnElement, SVGLine.y2),
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGPath.elementName: {
                var returnElement = SVGPath()
                returnElement.supportedAttributes = [
                    "d": unown(returnElement, SVGPath.parseD),
                    "clip-rule": unown(returnElement, SVGPath.clipRule),
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGPolygon.elementName: {
                var returnElement = SVGPolygon()
                returnElement.supportedAttributes = [
                    "points":  returnElement.points,
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGPolyline.elementName: {
                var returnElement = SVGPolyline()
                returnElement.supportedAttributes = [
                    "points":  returnElement.points,
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGRectangle.elementName: {
                var returnElement = SVGRectangle()
                returnElement.supportedAttributes = [
                    "height": unown(returnElement, SVGRectangle.rectangleHeight),
                    "rx": unown(returnElement, SVGRectangle.xCornerRadius),
                    "ry": unown(returnElement, SVGRectangle.yCornerRadius),
                    "width": unown(returnElement, SVGRectangle.rectangleWidth),
                    "x": unown(returnElement, SVGRectangle.parseX),
                    "y": unown(returnElement, SVGRectangle.parseY),
                ]
                returnElement.addStandardAttributes()
                return returnElement
            },
            SVGRootElement.elementName: {
                var returnElement = SVGRootElement()
                returnElement.supportedAttributes.add(returnElement.identityAttributes)
                return returnElement
            }
            
        ]
        return SVGParserSupportedElements(tags: supportedElements)
    }
    
}

private extension SVGShapeElement {

    /// Adds the attribute families shared by every shape element supported by the default parser.
    mutating func addStandardAttributes() {
        self.supportedAttributes.add(self.identityAttributes)
        self.supportedAttributes.add(self.fillAttributes)
        self.supportedAttributes.add(self.strokeAttributes)
        self.supportedAttributes.add(self.styleAttributes)
        self.supportedAttributes.add(self.transformAttributes)
    }
}

private extension SVGGroup {

    /// Adds the attribute families shared by the group and shape elements supported by the default parser.
    func addStandardAttributes() {
        self.supportedAttributes.add(self.identityAttributes)
        self.supportedAttributes.add(self.fillAttributes)
        self.supportedAttributes.add(self.strokeAttributes)
        self.supportedAttributes.add(self.styleAttributes)
        self.supportedAttributes.add(self.transformAttributes)
    }
}
