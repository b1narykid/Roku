//
//  BaseStackTemplate.swift
//  Roku
//
// Copyright © 2015 Ivan Trubach
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

import Swift
import CoreData

/// Default `CoreData` stack template.
///
/// This stack consists of one root managed object context
/// initialized with the prefered concurrency type.
///
/// Creating contexts on the same layer
/// with automatic changes merging is supported.
/// You may add as much child background contexts as needed.
///
/// - Remark:    I included this stack as a template for other stacks.
///              This stack template can be used for designing stacks
///              with multiple persistent store coordinators for `Roku`.
///
/// - SeeAlso: `BaseStack`, `NestedStackTemplate`, `IndependentStackTemplate`
public protocol BaseStackTemplate: ContextFactoryStack {
    /// Persistent store coordinator used by managed object contexts.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get }
    /// Root managed object context.
    ///
    /// - Note: Should be with `PrivateQueueConcurrencyType` concurrency type.
    var masterObjectContext: NSManagedObjectContext { get }
    /// Save changes in contexts to the persistent store coordinator.
    ///
    /// - Remark: Does not save worker contexts.
    mutating func trySave(repeatOnError error: ErrorType -> Bool)
    /// Create new context for this template.
    mutating func createContext(concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext
}

public extension BaseStackTemplate {
    /// Save changes in all contexts (implemented in this template) to persistent store.
    ///
    /// - Parameter repeatOnError: Callback closure. Informs caller about the error.
    ///                            Should return `true` if can retry context save.
    ///                            Otherwise, return false or you will get
    ///                             an infinite save attempts.
    public mutating func trySave(repeatOnError error: ErrorType -> Bool = { _ in return false }) {
        self.trySaveContext(self.masterObjectContext, callback: error)
    }
    
    /// Create new context for this template.
    ///
    /// - Note: New managed object context is a child of `self.masterObjectContext`.
    ///
    /// - Parameter concurrencyType: `NSManagedObjectContextConcurrencyType` of new managed object context.
    ///                              The default value is `PrivateQueueConcurrencyType`.
    public mutating func createContext(concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType) -> NSManagedObjectContext {
        let context = ManagedObjectContext(concurrencyType: concurrencyType)
        context.parentContext = self.masterObjectContext
        return context
    }
}

// MARK: Saving support

internal extension BaseStackTemplate {
    /// Try saving context.
    ///
    /// Provides the internal functionality 
    /// for saving single context from stack
    /// with synchrounous saving and error callback.
    internal mutating func trySaveContext(context: NSManagedObjectContext, callback: ErrorType -> Bool) {
        self.masterObjectContext.performBlockAndWait {
            do {
                try context.save()
            } catch {
                // Should I (stack instance) retry save again?
                // May be you (user) want to fix something?
                guard callback(error) else { return }
                // Retrying save operation.
                self.trySaveContext(context, callback: callback)
            }
        }
    }
}
