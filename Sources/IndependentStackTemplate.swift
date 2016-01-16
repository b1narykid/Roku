//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  IndependentStackTemplate.swift
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

/// Concurrent stack template with independent managed object contexts.
///
/// This stack consists of two independent managed object contexts
/// which are both connected to the same persistent store coordinator.
/// One of the contexts is set up on the main queue,
/// the other one on a background queue.
///
/// - Attention: In this setup the background context is used for the data import.
///   The setup is a more conservative stack which does not use
///   the relatively new feature of nested managed object contexts.
///
/// - Remark: Change propagation between the contexts is achieved by subscribing
///   to the `NSManagedObjectContextDidSaveNotification` and calling
///   `mergeChangesFromContextDidSaveNotification()` on the other context.
///
/// - SeeAlso:   `IndependentStack`, `BaseStackTemplate`, `NestedStackTemplate`
public protocol IndependentStackTemplate: CoreStackTemplate, MainQueueContextStack {
    /// Root managed object context.
    ///
    /// - Important: Managed object context has private queue concurrency type.
    var masterObjectContext: NSManagedObjectContext { get }
    /// Main managed object context.
    ///
    /// - Note: Should be independent with `.MainQueueConcurrencyType`
    ///   and work only with `self.persistentStoreCoordinator`.
    var mainObjectContext: NSManagedObjectContext { get }

}

public extension IndependentStackTemplate where Self: SavableStack {
    /// Save changes in all contexts (except main queue context)
    /// implemented in this template to the persistent store.
    ///
    /// - Note: Main queue and worker contexts
    ///   are not being saved in this method.
    ///
    /// - Parameter stopOnError: Callback closure. Informs caller about the error.
    ///   Should return `true` if can retry context save.
    ///   Otherwise, return false or you will get an infinite save attempts.
    public mutating func trySave(
        stopOnError error: ErrorType -> Bool = { _ in return false }
    ) {
        // Main queue context will be notified about change.
        // There is no need in saving main queue
        // because it should not be used for data imports.
        self.trySaveContext(self.masterObjectContext, callback: error)
    }
}

public extension IndependentStackTemplate where Self: protocol<ContextFactoryStack, StorageBased> {
    /// Create new context for this template.
    ///
    /// - Parameter concurrencyType: Concurrency type of managed object context.
    ///   Defaults to `PrivateQueueConcurrencyType`.
    ///
    /// - Returns: New independent managed object context with
    ///   `self.persistentStoreCoordinator` persistent store coordinator.
    public mutating func createContext(
        concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType
    ) -> NSManagedObjectContext {
        let context = ManagedObjectContext(concurrencyType: concurrencyType)
        context.persistentStoreCoordinator = self.storage.persistentStoreCoordinator
        return context
    }
}
