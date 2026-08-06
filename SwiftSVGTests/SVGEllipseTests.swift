//
//  SVGEllipseTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class SVGEllipseTests: XCTestCase {
    
    func testElementName() {
        XCTAssert(SVGEllipse.elementName == "ellipse", "Expected \"ellipse\", got \(SVGEllipse.elementName)")
    }
    
}
