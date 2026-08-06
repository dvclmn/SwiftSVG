//
//  CGPathPoints.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//


#if os(iOS) || os(tvOS)
import UIKit
#endif


extension CGPath {
    
    var points: [CGPoint] {
        var arrayPoints = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            case .closeSubpath:
                arrayPoints.append(element.points[0])
            }
        }
        return arrayPoints
    }
    
    var pointsAndTypes: [(CGPoint, CGPathElementType)] {
        var arrayPoints = [(CGPoint, CGPathElementType)]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append((element.points[0], .moveToPoint))
            case .addLineToPoint:
                arrayPoints.append((element.points[0], .addLineToPoint))
            case .addQuadCurveToPoint:
                arrayPoints.append((element.points[0], .addQuadCurveToPoint))
                arrayPoints.append((element.points[1], .addQuadCurveToPoint))
            case .addCurveToPoint:
                arrayPoints.append((element.points[0], .addCurveToPoint))
                arrayPoints.append((element.points[1], .addCurveToPoint))
                arrayPoints.append((element.points[2], .addCurveToPoint))
            case .closeSubpath:
                arrayPoints.append((element.points[0], .closeSubpath))
            }
        }
        return arrayPoints
    }
    
    private func forEach(body: @escaping @convention(block) (CGPathElement) -> ()) {
        typealias Body = @convention(block) (CGPathElement) -> ()
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> () = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
}

extension PathCommand {
    
    init(parameters: [Double], pathType: PathType, path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        self.init(pathType: pathType)
        self.coordinateBuffer = parameters
        self.execute(on: path, previousCommand: previousCommand)
    }
    
}




