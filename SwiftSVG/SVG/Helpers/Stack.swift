//
//  Stack.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//

import Foundation

/// A protocol that describes an instance that can act as a stack data structure
protocol StackType {
  associatedtype StackItem
  var items: [StackItem] { get set }
  init()
  mutating func pop() -> StackItem?
  mutating func push(_ itemToPush: StackItem)
}

/// A stack data structure
internal struct Stack<T>: StackType {
  var items: [T] = []
  init() {}
}

extension StackType {

  /// Default implementation of popping the last element off the stack
  @discardableResult
  mutating func pop() -> StackItem? {
    guard self.items.count > 0 else {
      return nil
    }
    return self.items.removeLast()
  }

  /// Push a new element on to the stack
  mutating func push(_ itemToPush: StackItem) {
    self.items.append(itemToPush)
  }

  /// Clear all elements from the stack
  mutating func clear() {
    self.items.removeAll()
  }

  /// Returns the number of elements on the stack
  var count: Int {
    return self.items.count
  }

  /// Check whether the stack is empty or not
  var isEmpty: Bool {
    if self.items.count == 0 {
      return true
    }
    return false
  }

  /// Return the last element on the stack without popping it off the stack.
  /// Equivalent to peek in other stack implementations
  var last: StackItem? {
    if self.isEmpty == false {
      return self.items.last
    }
    return nil
  }

}
