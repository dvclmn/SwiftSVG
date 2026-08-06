//
//  SVGPathTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGPathTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGPath.elementName == "path", "Expected \"path\", got \(SVGPath.elementName)")
    }
    
}
