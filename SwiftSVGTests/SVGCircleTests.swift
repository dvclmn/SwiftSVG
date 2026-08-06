//
//  SVGCircleTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class SVGCircleTests: XCTestCase {

    func testElementName() {
        XCTAssert(SVGCircle.elementName == "circle", "Expected \"circle\", got \(SVGCircle.elementName)")
    }
    
    func testSettingValues () {
        let testCircle = SVGCircle()
        testCircle.xCenter(x: "40.3")
        testCircle.yCenter(y: "108.254")
        
        XCTAssert(testCircle.circleCenter == CGPoint(x: 40.3, y: 108.254), "Expected {40.3, 108.254}, got \(testCircle.circleCenter)")
        
        testCircle.radius(r: "435.10")
        XCTAssert(testCircle.circleRadius == 435.1, "Expected 435.1, got \(testCircle.circleRadius)")
        
        testCircle.radius(r: "1e3")
        XCTAssert(testCircle.circleRadius == 1000, "Expected 1000, got \(testCircle.circleRadius)")
    }

}
