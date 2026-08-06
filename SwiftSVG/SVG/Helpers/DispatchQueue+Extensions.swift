//
//  DispatchQueue+Extensions.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

import Foundation

extension DispatchQueue {

  /// An extension that will immediately execute the given block if already on the main thread
  internal func safeAsync(_ block: @escaping () -> Void) {
    if self === DispatchQueue.main && Thread.isMainThread {
      block()
    } else {
      self.async {
        block()
      }
    }
  }
}
