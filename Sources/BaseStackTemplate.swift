//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  BaseStackTemplate.swift
//  Roku
//
// Copyright © 2016 Ivan Trubach
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

import Swift
import CoreData

/// Default `CoreData` stack template.
///
/// This stack consists of one root managed object context
/// initialized with the private concurrency type.
///
/// Creating contexts on the same layer
/// with automatic changes merging is supported.
/// You may add as much child background contexts as needed.
///
/// - Note: I included this stack as a template for other stacks.
///   This stack template can be used for designing stacks
///   with multiple persistent store coordinators for `Roku`.
///
/// - SeeAlso: `BaseStack`, `NestedStackTemplate`, `IndependentStackTemplate`
public protocol BaseStackTemplate: CoreStackTemplate {
    /// Root managed object context.
    ///
    /// - Note: Should be with `PrivateQueueConcurrencyType` concurrency type.
    var masterObjectContext: NSManagedObjectContext { get }
}

public extension BaseStackTemplate where Self: SavableStack {
    /// Save changes in all contexts implemented in this template
    /// to the persistent store.
    ///
    /// - Note: Worker contexts are not saved.
    ///
    /// - Parameter stopOnError: Callback closure. Informs caller about the error.
    ///   Should return `true` if can retry context save.
    ///   Otherwise, return false or you will get an infinite save attempts.
    public mutating func trySave(
        stopOnError error: ErrorType -> Bool = { _ in return false }
    ) {
            self.trySaveContext(self.masterObjectContext, callback: error)
    }
}

public extension BaseStackTemplate where Self: ContextFactoryStack {
    /// Create new context for this template.
    ///
    /// - Parameter concurrencyType: Concurrency type of managed object context.
    ///   Defaults to `PrivateQueueConcurrencyType`.
    ///
    /// - Returns: New `ManagedObjectContext` instance as
    ///   a child of `self.masterObjectContext`.
    public mutating func createContext(
        concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType
    ) -> NSManagedObjectContext {
        let context = ManagedObjectContext(concurrencyType: concurrencyType)
        context.parentContext = self.masterObjectContext
        return context
    }
}
