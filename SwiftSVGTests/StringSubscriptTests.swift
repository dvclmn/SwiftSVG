//
//  StringSubscriptTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import XCTest

class StringSubscriptTests: XCTestCase {
    
    func testIntegerRange() {
        
        let testString = "1234567890"
        
        XCTAssertTrue(testString[0..<3] == "123", "Expected \"123\", got \(testString[0..<2])")
        XCTAssertTrue(testString[3..<7] == "4567", "Expected \"4567\", got \(testString[3..<7])")
        
    }
    
}
