//
//  MoveTo.swift
//  SwiftSVG
//
//  Created by Dave Coleman on 24/2/2026.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

/// The `PathCommand` that corresponds to the SVG `M` or `m` command
internal struct MoveTo: PathCommand {

  internal var coordinateBuffer: [Double] = []
  internal let numberOfRequiredParameters = 2
  internal let pathType: PathType
  internal init(pathType: PathType) {
    self.pathType = pathType
  }

  /// This will move the current point to
  /// `CGPoint(self.coordinateBuffer[0], self.coordinateBuffer[1])`.
  /// Sequential MoveTo commands should be treated as LineTos.
  /// From Docs (https://www.w3.org/TR/SVG2/paths.html#PathDataMovetoCommands):
  ///
  /// > Start a new sub-path at the given (x,y) coordinates.
  /// > M (uppercase) indicates that absolute coordinates will follow;
  /// > m (lowercase) indicates that relative coordinates will follow.
  /// > If a moveto is followed by multiple pairs of coordinates,
  /// > the subsequent pairs are treated as implicit lineto commands.
  /// > Hence, implicit lineto commands will be relative if the moveto is
  /// > relative, and absolute if the moveto is absolute.
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {

    if previousCommand is MoveTo {
      var implicitLineTo = LineTo(pathType: self.pathType)
      implicitLineTo.coordinateBuffer = [self.coordinateBuffer[0], self.coordinateBuffer[1]]
      implicitLineTo.execute(on: path)
      return
    }

    let point = self.pointForPathType(
      CGPoint(x: self.coordinateBuffer[0], y: self.coordinateBuffer[1]), relativeTo: path.currentPoint)
    path.move(to: point)
  }
}
