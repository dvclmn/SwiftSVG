//
//  SVGLineTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGLineTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGLine.elementName == "line", "Expected \"line\", got \(SVGLine.elementName)")
    }
    
}
