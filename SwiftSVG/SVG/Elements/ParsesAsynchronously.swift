//
//  ParsesAsynchronously.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif


/// A protocol describing an instance that can manage elements that can parse asynchronously.
/// In the `NSXMLSVGParser` implementation, the parser maintains a simple count of pending
/// asynchronous tasks and decrements the count when an element has finished parsing.
/// When the count has reached zero, a completion block is called
protocol CanManageAsychronousParsing {
    /// The callback called when an `ParsesAsynchronously` element has finished parsing
    /// - Parameter shapeLayer: The completed layer
    func finishedProcessing(_ shapeLayer: CAShapeLayer, shouldResizeBounds: Bool)
}

/// A protocol describing an instance that parses asynchronously
protocol ParsesAsynchronously {
    /// The delegate instance that can manage asynchronous parsing
    var asyncParseManager: CanManageAsychronousParsing? { get set }
}
