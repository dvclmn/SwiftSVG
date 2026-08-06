//
//  SVGGroupTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGGroupTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGGroup.elementName == "g", "Expected \"g\", got \(SVGGroup.elementName)")
    }
    
}
