//
//  SVGPolygonTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGPolygonTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGPolygon.elementName == "polygon", "Expected \"polygon\", got \(SVGPolygon.elementName)")
    }
    
}
