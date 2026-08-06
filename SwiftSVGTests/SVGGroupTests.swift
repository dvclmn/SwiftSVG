//
//  SVGGroupTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGGroupTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGGroup.elementName == "g", "Expected \"g\", got \(SVGGroup.elementName)")
    }
    
}
