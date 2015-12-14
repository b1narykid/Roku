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
import CoreData

/// Default `CoreData` stack implementation.
///
/// This stack consists of a main managed object context
/// initialized with the `MainQueueConcurrencyType`, and a background
/// managed object context initialized with the `PrivateQueueConcurrencyType`.
/// The main context is configured to be the parent context of the background context.
///
/// - Warning:   This is a not so smart solution you sometimes see or read about.
///              I included this stack implementation as a superclass for other stacks.
///
/// - Attention: In this setup the background context
///              should be used for the data import.
///
/// - Remark:    All properties are lazy-initialized.
///              All `ManagedObjectContext`'s changes are fully synchronized.
///              You may wish to inherit from this class to make your custom stack.
///
/// - SeeAlso:   `BaseStackTemplate`, `NestedStack`, `IndependentStack`, [Illustration](http://floriankugler.com/images/cd-stack-1-dabcc12e.png)
public class BaseStack: StorageModelBased, BaseStackTemplate, StorageModelConvertible {
    /// Initialize with `StorageModel` instance.
    public required init(storage: StorageModel) {
        self.storage = storage
    }
    
    /// Storage used by managed object contexts.
    public internal(set) var storage: StorageModel
    
    /// Root (main) managed object context.
    ///
    /// - Note:   Independent and works with `self.persistentStoreCoordinator`.
    /// - Remark: Main queue concurrency type.
    public internal(set) lazy var masterObjectContext: NSManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
}
