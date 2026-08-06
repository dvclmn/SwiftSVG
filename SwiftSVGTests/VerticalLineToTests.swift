//
//  VerticalLineToTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class VerticalLineToTests: XCTestCase {

    func testAbsoluteVerticalLineTo() {
        let testPath = UIBezierPath()
        _ = MoveTo(parameters: [10, -20], pathType: .absolute, path: testPath)
        _ = VerticalLineTo(parameters: [-128], pathType: .absolute, path: testPath)
        let points = testPath.cgPath.points
        XCTAssert(points[1].x == 10 && points[1].y == -128, "Expected {10, -128}, got \(points[1])")
    }
    
    func testRelativeVerticalLineTo() {
        let testPath = UIBezierPath()
        _ = MoveTo(parameters: [10, -20], pathType: .absolute, path: testPath)
        _ = VerticalLineTo(parameters: [-128], pathType: .relative, path: testPath)
        let points = testPath.cgPath.points
        XCTAssert(points[1].x == 10 && points[1].y == -148, "Expected {10, -148}, got \(points[1])")
    }

}
