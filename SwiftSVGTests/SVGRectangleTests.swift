//
//  SVGRectangleTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGRectangleTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGRectangle.elementName == "rect", "Expected \"rect\", got \(SVGRectangle.elementName)")
    }
    
}
