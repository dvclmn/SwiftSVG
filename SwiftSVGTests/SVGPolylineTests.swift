//
//  SVGPolylineTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGPolylineTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGPolyline.elementName == "polyline", "Expected \"polyline\", got \(SVGPolyline.elementName)")
    }
    
}
