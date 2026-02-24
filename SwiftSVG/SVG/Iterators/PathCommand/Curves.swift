//
//  Curve.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 24/2/2026.
//

import Foundation

/// The `PathCommand` that corresponds to the SVG `C` or `c` command
internal struct CurveTo: PathCommand {

  internal var coordinateBuffer: [Double] = []
  internal let numberOfRequiredParameters = 6
  internal let pathType: PathType

  internal init(pathType: PathType) {
    self.pathType = pathType
  }

  /// Adds a cubic Bezier curve to `path`. The path will end up at
  /// `CGPoint(self.coordinateBuffer[4], self.coordinateBuffer[5])`.
  /// The control point for `path.currentPoint` will be
  /// `CGPoint(self.coordinateBuffer[0], self.coordinateBuffer[1])`.
  /// Then control point for the end point will be CGPoint(self.coordinateBuffer[2], self.coordinateBuffer[3])
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    let startControl = self.pointForPathType(
      CGPoint(
        x: self.coordinateBuffer[0],
        y: self.coordinateBuffer[1]
      ),
      relativeTo: path.currentPoint
    )
    let endControl = self.pointForPathType(
      CGPoint(
        x: self.coordinateBuffer[2],
        y: self.coordinateBuffer[3]
      ),
      relativeTo: path.currentPoint
    )
    let point = self.pointForPathType(
      CGPoint(
        x: self.coordinateBuffer[4],
        y: self.coordinateBuffer[5]
      ),
      relativeTo: path.currentPoint
    )
    path.addCurve(to: point, controlPoint1: startControl, controlPoint2: endControl)
  }
}

/// The `PathCommand` that corresponds to the SVG `S` or `s` command
internal struct SmoothCurveTo: PathCommand {

  internal var coordinateBuffer: [Double] = []
  internal let numberOfRequiredParameters = 4
  internal let pathType: PathType

  internal init(pathType: PathType) {
    self.pathType = pathType
  }

  /// Shortcut cubic Bezier curve to that add a new path ending up at `CGPoint(self.coordinateBuffer[0], self.coordinateBuffer[1])` with a single control point in the middle.
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {

    let point = self.pointForPathType(
      CGPoint(
        x: self.coordinateBuffer[2],
        y: self.coordinateBuffer[3]
      ),
      relativeTo: path.currentPoint
    )
    let controlEnd = self.pointForPathType(
      CGPoint(
        x: self.coordinateBuffer[0],
        y: self.coordinateBuffer[1]
      ),
      relativeTo: path.currentPoint
    )

    let controlStart: CGPoint
    if let previousCurveTo = previousCommand as? CurveTo {
      switch previousCurveTo.pathType {
        case .absolute:
          controlStart = CGPoint(
            x: Double(2.0 * path.currentPoint.x) - previousCurveTo.coordinateBuffer[2],
            y: Double(2.0 * path.currentPoint.y) - previousCurveTo.coordinateBuffer[3]
          )
        case .relative:
          let oldCurrentPoint = (
            Double(path.currentPoint.x) - previousCurveTo.coordinateBuffer[4],
            Double(path.currentPoint.y) - previousCurveTo.coordinateBuffer[5]
          )
          controlStart = CGPoint(
            x: Double(2.0 * path.currentPoint.x) - (previousCurveTo.coordinateBuffer[2] + oldCurrentPoint.0),
            y: Double(2.0 * path.currentPoint.y) - (previousCurveTo.coordinateBuffer[3] + oldCurrentPoint.1)
          )
      }
    } else if let previousSmoothCurveTo = previousCommand as? SmoothCurveTo {
      switch previousSmoothCurveTo.pathType {
        case .absolute:
          controlStart = CGPoint(
            x: Double(2.0 * path.currentPoint.x) - previousSmoothCurveTo.coordinateBuffer[0],
            y: Double(2.0 * path.currentPoint.y) - previousSmoothCurveTo.coordinateBuffer[1]
          )
        case .relative:
          let oldCurrentPoint = (
            Double(path.currentPoint.x) - previousSmoothCurveTo.coordinateBuffer[2],
            Double(path.currentPoint.y) - previousSmoothCurveTo.coordinateBuffer[3]
          )
          controlStart = CGPoint(
            x: Double(2.0 * path.currentPoint.x)
              - (previousSmoothCurveTo.coordinateBuffer[0] + oldCurrentPoint.0),
            y: Double(2.0 * path.currentPoint.y)
              - (previousSmoothCurveTo.coordinateBuffer[1] + oldCurrentPoint.1)
          )
      }
    } else {
      controlStart = path.currentPoint
    }
    path.addCurve(to: point, controlPoint1: controlStart, controlPoint2: controlEnd)
  }
}


/// The `PathCommand` that corresponds to the SVG `T` or `t` command
internal struct SmoothQuadraticCurveTo: PathCommand {
  
  internal var coordinateBuffer: [Double] = []
  
  internal let numberOfRequiredParameters = 2
  
  internal let pathType: PathType
  
  internal var previousControlPoint: CGPoint? = nil
  
  internal init(pathType: PathType) {
    self.pathType = pathType
  }
  
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    
    let point = self.pointForPathType(
      CGPoint(x: self.coordinateBuffer[0], y: self.coordinateBuffer[1]), relativeTo: path.currentPoint)
    
    var controlPoint: CGPoint
    if let previousQuadraticCurveTo = previousCommand as? QuadraticCurveTo {
      switch previousQuadraticCurveTo.pathType {
        case .absolute:
          controlPoint = CGPoint(
            x: Double(2.0 * path.currentPoint.x) - previousQuadraticCurveTo.coordinateBuffer[0],
            y: Double(2.0 * path.currentPoint.y) - previousQuadraticCurveTo.coordinateBuffer[1]
          )
        case .relative:
          let oldCurrentPoint = (
            Double(path.currentPoint.x) - previousQuadraticCurveTo.coordinateBuffer[2],
            Double(path.currentPoint.y) - previousQuadraticCurveTo.coordinateBuffer[3]
          )
          controlPoint = CGPoint(
            x: Double(2.0 * path.currentPoint.x) - previousQuadraticCurveTo.coordinateBuffer[0]
            + oldCurrentPoint.0,
            y: Double(2.0 * path.currentPoint.y) - previousQuadraticCurveTo.coordinateBuffer[1]
            + oldCurrentPoint.1
          )
      }
    } else {
      controlPoint = path.currentPoint
    }
    path.addQuadCurve(to: point, controlPoint: controlPoint)
  }
}

/// The `PathCommand` that corresponds to the SVG `Q` or `q` command
internal struct QuadraticCurveTo: PathCommand {
  
  internal var coordinateBuffer: [Double] = []
  
  internal let numberOfRequiredParameters = 4
  
  internal let pathType: PathType
  
  internal init(pathType: PathType) {
    self.pathType = pathType
  }
  
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    let controlPoint = self.pointForPathType(
      CGPoint(x: self.coordinateBuffer[0], y: self.coordinateBuffer[1]), relativeTo: path.currentPoint)
    let point = self.pointForPathType(
      CGPoint(x: self.coordinateBuffer[2], y: self.coordinateBuffer[3]), relativeTo: path.currentPoint)
    path.addQuadCurve(to: point, controlPoint: controlPoint)
  }
}
