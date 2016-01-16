//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  BaseStack.swift
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

/// Default `CoreData` stack implementation.
///
/// This stack consists of one root managed object context
/// initialized with the `PrivateQueueConcurrencyType`.
///
/// Creating contexts on the same layer
/// with automatic changes merging is supported.
/// You may add as much child background contexts as needed.
///
/// All properties are lazy-initialized.
/// You may wish to inherit from this class to make your custom stack.
///
/// - Note: I included this stack as a superclass for other stacks.
///   This stack can be used in multiple persistent store coordinators stacks
///   with `Roku` (its `masterObjectContext` is `PrivateQueueConcurrencyType`).
///
/// - Attention: In this setup the background or root context
///   should be used for the data import.
///
/// - SeeAlso: `BaseStackTemplate`, `NestedStack`, `IndependentStack`
public class BaseStack: BaseStackTemplate, StorageModelBased, ContextFactoryStack, SavableStack {
    /// Initialize with `StorageModel` instance.
    ///
    /// - Parameters storage: Storage used by `self`.
    public required init(storage: StorageModel) {
        self.storage = storage
    }

    /// Storage used by managed object contexts.
    public internal(set) var storage: StorageModel

    /// Root managed object context.
    ///
    /// - Note: Independent and works with `self.persistentStoreCoordinator`.
    ///   Managed object context has private queue concurrency type.
    public internal(set) lazy var masterObjectContext: NSManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storage.persistentStoreCoordinator
        return context
    }()
}
