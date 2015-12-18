//
//  BaseStack.swift
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
// Classes
import class CoreData.NSManagedObjectContext
// Enums
import enum CoreData.NSManagedObjectContextConcurrencyType

/// Default `CoreData` stack implementation.
///
/// This stack consists of one root managed object context
/// initialized with the `PrivateQueueConcurrencyType`.
///
/// Creating contexts on the same layer 
/// with automatic changes merging is supported.
/// You may add as much child background contexts as needed.
///
/// - Warning:   I included this stack implementation as a superclass for other stacks.
///              But this stack can be used in multiple persistent store coordinators stacks
///              with `Roku` (its `masterObjectContext` is `PrivateQueueConcurrencyType`).
///
/// - Attention: In this setup the background or root context
///              should be used for the data import.
///
/// - Remark:    All properties are lazy-initialized.
///              All `ManagedObjectContext`'s changes are fully synchronized.
///              You may wish to inherit from this class to make your custom stack.
///
/// - SeeAlso:   `BaseStackTemplate`, `NestedStack`, `IndependentStack`
public class BaseStack: StorageModelBasedStack {
    /// Initialize with `StorageModel` instance.
    public required init(storage: StorageModel) {
        self.storage = storage
    }
    
    /// Storage used by managed object contexts.
    public internal(set) var storage: StorageModel
    
    /// Root managed object context.
    ///
    /// - Note:   Independent and works with `self.persistentStoreCoordinator`.
    /// - Remark: Private queue concurrency type.
    public internal(set) lazy var masterObjectContext: NSManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
}
