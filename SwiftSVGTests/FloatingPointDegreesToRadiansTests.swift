//
//  FloatingPointDegreesToRadiansTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class FloatingPointDegreesToRadiansTests: XCTestCase {
    
    func testToRadians() {
        let degrees: Double = 180.0
        XCTAssert(degrees.toRadians == Double.pi, "Expected pi, got \(degrees.toRadians)")
    }
    
    func testToDegrees() {
        let radians: Double = Double.pi
        XCTAssert(radians.toDegrees == 180, "Expected 180, got \(radians.toDegrees)")
    }
    
}
