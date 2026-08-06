//
//  SVGPolylineTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGPolylineTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGPolyline.elementName == "polyline", "Expected \"polyline\", got \(SVGPolyline.elementName)")
    }
    
}
