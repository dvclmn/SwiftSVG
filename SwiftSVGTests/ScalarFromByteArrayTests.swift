//
//  ScalarFromByteArrayTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class ScalarFromByteArrayTests: XCTestCase {

    func testByteArray() {
        var testArray: [CChar] = [49, 48]
        var asDouble = Double(byteArray: testArray)!
        XCTAssert(asDouble == 10, "Expected 10, got \(asDouble)")
        
        testArray = [45, 57, 49, 53]
        asDouble = Double(byteArray: testArray)!
        XCTAssert(asDouble == -915, "Expected -915, got \(asDouble)")
        
        testArray = [45, 54, 46, 51, 56]
        asDouble = Double(byteArray: testArray)!
        XCTAssert(asDouble == -6.38, "Expected -6.38, got \(asDouble)")
    }
    
    func testInvalidByteArray() {
        var testArray: [CChar] = [65, 48]       // "A0"
        var asDouble = Double(byteArray: testArray)
        XCTAssertNil(asDouble, "Expected nil, got \(String(describing: asDouble))")
        
        testArray = []
        asDouble = Double(byteArray: testArray)
        XCTAssertNil(asDouble, "Expected nil, got \(String(describing: asDouble))")
    }
    
    func testENumber() {
        let testArray: [CChar] = [49, 101, 51] // "1e3
        let asDouble = Double(byteArray: testArray)
        XCTAssert(asDouble == 1000, "Double: \(asDouble!)")
    }
    
    func testZeroCountArray() {
        let testArray = [CChar]()
        let asDouble = Double(byteArray: testArray)
        XCTAssertNil(asDouble, "Expected nil, got \(String(describing: asDouble))")
    }

}
