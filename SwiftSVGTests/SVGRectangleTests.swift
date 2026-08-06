//
//  SVGRectangleTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGRectangleTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGRectangle.elementName == "rect", "Expected \"rect\", got \(SVGRectangle.elementName)")
    }
    
}
