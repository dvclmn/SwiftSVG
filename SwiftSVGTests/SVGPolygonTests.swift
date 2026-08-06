//
//  SVGPolygonTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGPolygonTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGPolygon.elementName == "polygon", "Expected \"polygon\", got \(SVGPolygon.elementName)")
    }
    
}
