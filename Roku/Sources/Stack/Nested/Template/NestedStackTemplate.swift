//
//  NestedStackTemplate.swift
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

/// Concurrent stack template with nested managed object contexts.
///
/// This stack consists of three layers.
/// First layer is a writer (master) managed object context
/// with the private concurrency type (operating on a background thread).
/// Second layer consists of a main thread’s
/// managed object context as a child of this master context.
/// Third layer consists of one or multiple worker contexts
/// as children of the main context in the private queue.
///
/// - Attention: In this setup the worker contexts on 
///              the third layer are used to import the data.
///
/// - Note:      There may be multiple contexts on the second and third layers.
///              Also, there may be worker contexts on the second layer.
///
/// - SeeAlso:   `NestedStack`, `BaseStackTemplate`, `IndependentStackTemplate`
public protocol NestedStackTemplate: BaseStackTemplate, MainQueueContextStack {
    /// Persistent store coordinator used by managed object contexts.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get }
    /// Root managed object context.
    ///
    /// - Note: Should be with `PrivateQueueConcurrencyType` concurrency type.
    var masterObjectContext: NSManagedObjectContext { get }
    /// Main managed object context.
    ///
    /// - Note: Should be with `.MainQueueConcurrencyType` and
    ///         child context of `self.masterObjectContext`.
    var mainObjectContext: NSManagedObjectContext { get }
    /// Save changes in all contexts implemented in template
    /// to the persistent store coordinator.
    mutating func trySave(stopOnError error: ErrorType -> Bool)
    /// Create new worker context for this template.
    mutating func createContext(concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext
}

public extension NestedStackTemplate {
    /// Save changes in all contexts (implemented in this template) to persistent store.
    ///
    /// - Note: Worker contexts are being not saved in this method.
    ///
    /// - Parameter repeatOnError: Callback closure. Informs caller about the error.
    ///                            Should return `true` if can retry context save.
    ///                            Otherwise, return false or you will get
    ///                            an infinite save attempts.
    public mutating func trySave(repeatOnError error: ErrorType -> Bool = { _ in return false }) {
        // Save second (2) layer.
        self.trySaveContext(self.mainObjectContext, callback: error)
        // Save first (1) layer.
        self.trySaveContext(self.masterObjectContext, callback: error)
    }
    
    /// Create new context for this template.
    ///
    /// - Note: New managed object context is a child of `self.mainObjectContext`.
    ///
    /// - Parameter concurrencyType: `NSManagedObjectContextConcurrencyType` of new managed object context.
    ///                              Defaults to `.PrivateQueueConcurrencyType`.
    public mutating func createContext(concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType) -> NSManagedObjectContext {
        let context = ManagedObjectContext(concurrencyType: concurrencyType)
        context.parentContext = self.mainObjectContext
        return context
    }
}
