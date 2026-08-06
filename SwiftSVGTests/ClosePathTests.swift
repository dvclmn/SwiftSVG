//
//  ClosePathTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class ClosePathTests: XCTestCase {

    func testClosePath() {
        let testPath = UIBezierPath()
        _ = MoveTo(parameters: [20, -30], pathType: .absolute, path:testPath)
        _ = ClosePath(parameters: [], pathType: .absolute, path:testPath)
        let lastPointAndType = testPath.cgPath.pointsAndTypes.last!
        XCTAssert(lastPointAndType.1 == .closeSubpath, "Expected .closeSubpath, got \(lastPointAndType.1)")
        XCTAssertEqual(lastPointAndType.0, CGPoint(x: 20, y: -30), "A close command should return to the current subpath's start point")
    }

}
