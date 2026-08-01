//
//  Lines.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 24/2/2026.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

/// The `PathCommand` that corresponds to the SVG `L` or `l` command
internal struct LineTo: PathCommand {
  
  internal var coordinateBuffer: [Double] = []
  
  internal let numberOfRequiredParameters = 2
  
  internal let pathType: PathType
  
  internal init(pathType: PathType) {
    self.pathType = pathType
  }
  
  /// Creates a line from the `path.currentPoint` to point `CGPoint(self.coordinateBuffer[0], coordinateBuffer[1])`
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    let point = self.pointForPathType(
      CGPoint(x: self.coordinateBuffer[0], y: self.coordinateBuffer[1]), relativeTo: path.currentPoint)
    path.addLine(to: point)
  }
}

/// The `PathCommand` that corresponds to the SVG `H` or `h` command
internal struct HorizontalLineTo: PathCommand {
  
  internal var coordinateBuffer: [Double] = []
  
  internal let numberOfRequiredParameters = 1
  
  internal let pathType: PathType
  
  internal init(pathType: PathType) {
    self.pathType = pathType
  }
  
  /// Adds a horizontal line from the currentPoint to `CGPoint(self.coordinateBuffer[0], path.currentPoint.y)`
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    let x = self.coordinateBuffer[0]
    let point =
    (self.pathType == .absolute
     ? CGPoint(x: CGFloat(x), y: path.currentPoint.y)
     : CGPoint(x: path.currentPoint.x + CGFloat(x), y: path.currentPoint.y))
    path.addLine(to: point)
  }
}

/// The `PathCommand` that corresponds to the SVG `V` or `v` command
internal struct VerticalLineTo: PathCommand {
  
  internal var coordinateBuffer: [Double] = []
  
  internal let numberOfRequiredParameters = 1
  
  internal let pathType: PathType
  
  internal init(pathType: PathType) {
    self.pathType = pathType
  }
  
  /// Adds a vertical line from the currentPoint to `CGPoint(path.currentPoint.y, self.coordinateBuffer[0])`
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    let y = self.coordinateBuffer[0]
    let point =
    (self.pathType == .absolute
     ? CGPoint(x: path.currentPoint.x, y: CGFloat(y))
     : CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + CGFloat(y)))
    path.addLine(to: point)
  }
}
