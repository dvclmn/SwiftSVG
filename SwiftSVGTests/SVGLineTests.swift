//
//  SVGLineTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGLineTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGLine.elementName == "line", "Expected \"line\", got \(SVGLine.elementName)")
    }
    
}
