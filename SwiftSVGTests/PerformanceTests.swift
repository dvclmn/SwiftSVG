//
//  PerformanceTests.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import XCTest

class PerformanceTests: XCTestCase {

    func testSwiftSVG() {
        
        self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            
            guard let resourceURL = Bundle(for: type(of: self)).url(forResource: "ukulele", withExtension: "svg") else {
                XCTAssert(false, "Couldn't find resource")
                return
            }
            
            let asData = try! Data(contentsOf: resourceURL)
            let expect = self.expectation(description: "SwiftSVG expectation")
            _ = UIView(svgData: asData) { (svgLayer) in
                SVGCache.default.removeObject(key: asData.cacheKey)
                expect.fulfill()
            }
            
            self.waitForExpectations(timeout: 10) { error in
                self.stopMeasuring()
            }
        }
        
        
    }

}
