//
//  TestShapeElement.swift
//  SwiftSVGTests
//
//  Copyright (c) 2017 Michael Choe
//

import UIKit

struct TestShapeElement: SVGShapeElement {
    static let elementName: String = "test"
    var supportedAttributes: [String : (String) -> ()] = [:]
    var svgLayer = CAShapeLayer()
    
    init() {
        let rectPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 200, height: 200))
        self.svgLayer.path = rectPath.cgPath
    }
    
    func notReal(string: String) {
        return
    }
    
    func didProcessElement(in container: SVGContainerElement?) {
        return
    }
}
