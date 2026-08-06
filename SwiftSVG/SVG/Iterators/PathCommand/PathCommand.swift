//
//  PathCommand.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

internal enum PathType {
  case absolute, relative
}

/// A protocol that describes an instance that can process an individual SVG Element
internal protocol PathCommand: PreviousCommand {

  /// An array that stores processed coordinates values
  var coordinateBuffer: [Double] { get set }

  /// The minimum number of coordinates needed to process the path command
  var numberOfRequiredParameters: Int { get }

  /// The path type, relative or absolute
  var pathType: PathType { get }

  /// Designated initializer that creates a relative or absolute `PathCommand`
  init(pathType: PathType)

  /// Once the `numberOfRequiredParameters` has been met, this method will append new path to the passed path
  /// - Parameter path: The path to append a new path to
  /// - Parameter previousCommand: An optional previous command. Used primarily with the shortcut cubic and quadratic Bezier types
  func execute(on path: UIBezierPath, previousCommand: PreviousCommand?)
}

/// A protocol that describes an instance that represents an SVGElement right before the current one
internal protocol PreviousCommand {

  /// An array that stores processed coordinates values
  var coordinateBuffer: [Double] { get }

  /// The path type, relative or absolute
  var pathType: PathType { get }
}

extension PathCommand {

  /// Default implementation for any `PathCommand` indicating where there are
  /// enough coordinates stored to be able to process the `SVGElement`
  var canPushCommand: Bool {
    if self.numberOfRequiredParameters == 0 {
      return true
    }
    if self.coordinateBuffer.count == 0 {
      return false
    }
    if self.coordinateBuffer.count % self.numberOfRequiredParameters == 0 {
      return true
    }
    return false
  }

  /// Function that clears the current number buffer
  mutating func clearBuffer() {
    self.coordinateBuffer.removeAll()
  }

  /// Adds a new coordinate to the buffer
  mutating func pushCoordinate(_ coordinate: Double) {
    self.coordinateBuffer.append(coordinate)
  }

  /// Based on the `PathType` of this PathCommand, this function returns the relative or absolute point
  func pointForPathType(_ point: CGPoint, relativeTo: CGPoint) -> CGPoint {
    switch self.pathType {
      case .absolute:
        return point
      case .relative:
        return CGPoint(x: point.x + relativeTo.x, y: point.y + relativeTo.y)
    }
  }
}

// MARK: - Implementations

/// The `PathCommand` that corresponds to the SVG `Z` or `z` command
internal struct ClosePath: PathCommand {

  internal var coordinateBuffer: [Double] = []
  internal let numberOfRequiredParameters = 0
  internal var pathType: PathType = .absolute

  internal init(pathType: PathType) {
    self.pathType = pathType
  }

  /// Closes the current path
  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    path.close()
  }
}

/// The `PathCommand` that corresponds to the SVG `A` or `a` command
// - TODO: Still needs an implementation
internal struct EllipticalArc: PathCommand {

  internal var coordinateBuffer: [Double] = []
  internal let numberOfRequiredParameters = 2
  internal let pathType: PathType

  internal init(pathType: PathType) {
    self.pathType = pathType
  }

  internal func execute(on path: UIBezierPath, previousCommand: PreviousCommand? = nil) {
    assert(false, "Needs Implementation")
  }
}
