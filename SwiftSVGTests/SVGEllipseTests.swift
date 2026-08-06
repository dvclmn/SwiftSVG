//
//  SVGEllipseTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGEllipseTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGEllipse.elementName == "ellipse", "Expected \"ellipse\", got \(SVGEllipse.elementName)")
    }
    
}
