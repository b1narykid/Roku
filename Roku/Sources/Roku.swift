//
//  StorageController.swift
//  Roku
//
//  Created by Ivan Trubach on 15.11.15.
//  Copyright © 2015 Ivan Trubach. All rights reserved.
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
@exported import CoreData

/// Generic wrapper over the `StorageModelBasedStack` `CoreData` stack.
///
/// Provides a convenience API for the `CoreData`'s context.
///
/// - SeeAlso: `BaseStack`, `BaseStackTemplate`, `NestedStack`, `NestedStackTemplate`, `IndependentStack`, `IndependentStackTemplate`
///
/// [Choosing `CoreData` stack for your purposes.][Article]
///
/// [Article]: http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/
public class Roku<ContextStack: StorageModelBasedStack>: StorageModelBased, StorageModelConvertible {
    public internal(set) var storage: StorageModel
    
    /// `CoreData` stack.
    private var _stack: ContextStack
    /// Context provider
    private lazy var _provider: Provider<NSManagedObjectContext> = {
        // Wrapper over context creation function.
        let provide = {
            return self._stack.createWorkerContext(concurrencyType: .PrivateQueueConcurrencyType)
        }
        
        return Provider(provider: provide)
    }()
    
    private lazy var _saveOprations: NSOperationQueue = {
        return NSOperationQueue.factory.createOprationQueue(
            name: "com.b1nary.Roku.roku_save_oq_\(unsafeAddressOf(self))"
        )
    }()
    
    public required init(storage: StorageModel) {
        self.storage = storage
        self._stack = ContextStack(storage: self.storage)
    }
    
    /// Call `body(c)`, where `c` is a temporary background `NSManagedObjectContext`.
    ///
    /// The temporary context is poped from the unused contexts queue.
    /// If no such context exists in queue, it is first created.
    ///
    /// - Note: Use the `body(c)` call to import/export data into/from context.
    ///         The save is handled by `Roku` in private background operation queue.
    ///         Don not rely on the context `c` beacause it may be reused by `Roku`.
    ///         External changes in `c` outside of `body(c)` may cause unexpected behaviours.
    ///
    /// - Parameter save: Save operation for context `c`. `save(c)` will be executed
    ///                   on the private context's background queue by `Roku`,
    ///                   you don not have to call `c.performBlock` to save cotnext
    ///                   in `save(c)` function. Just 'describe' how you want to save
    ///                   (and handle an errors) in this function.
    public func withBackgroundContext<R>(@noescape body: NSManagedObjectContext throws -> R, save: NSManagedObjectContext -> Void = { _ = try? $0.save() }) rethrows -> R {
        // Take worker from provider
        let worker = self._provider.take()
        
        defer {
            // Capture `_provider`, save opration and worker in background queue block.
            self._saveOprations.addOperationWithBlock { [weak _provider, save, worker] in
                // Perform `save(c)` handled by user.
                worker.performBlockAndWait { save(worker) }
                guard let provider = _provider else { return }
                provider.transmit(worker)
            }
        }
        
        return try body(worker)
    }
    
    /// Save data to persistent store.
    ///
    /// - Parameter errorCallback: Error callback. Should return `true` iff the error
    ///                            was handled (and 'fixed') and/or `Roku` may retry saving.
    public func persist(errorCallback: ErrorType -> Bool) {
        self._stack.trySave(repeatOnError: errorCallback)
    }
}
