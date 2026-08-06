//
//  IndentifiableTests.swift
//  SwiftSVGTests
//
//  Copyright (c) 2017 Michael Choe
//

import XCTest

class IndentifiableTests: XCTestCase {
    
    func testShapeElementSetsLayerName() {
        let testShapeElement = TestShapeElement()
        testShapeElement.identify(identifier: "id-to-check")
        XCTAssert(testShapeElement.svgLayer.name == "id-to-check", "Expected \"id-to-check\", got: \(String(describing: testShapeElement.svgLayer.name))")
    }
    
    func testEndToEnd() {
        
        guard let resourceURL = Bundle(for: type(of: self)).url(forResource: "simple-rectangle", withExtension: "svg") else {
            XCTAssert(false, "Couldn't find resource")
            return
        }
        
        let asData = try! Data(contentsOf: resourceURL)
        let expectation = self.expectation(description: "Identifiable expectation")
        _ = UIView(svgData: asData) { result in
            guard case .success(let svgLayer) = result else {
                XCTFail("Expected SVG parsing to succeed")
                return
            }

            guard let rootLayerName = svgLayer.sublayers?[0].name else {
                return
            }
            guard rootLayerName == "root-rectangle-id" else {
                return
            }
            
            guard let innerID = svgLayer.sublayers?[0].sublayers?[0].name else {
                return
            }
            guard innerID == "inner-rectangle-id" else {
                return
            }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3, handler: nil)
        
    }
    
}
