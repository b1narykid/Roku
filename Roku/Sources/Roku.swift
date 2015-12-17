//
//  StorageController.swift
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
@exported import CoreData

/// Encapsulates the `CoreData` stack.
///
/// Provides a convenience API for the `CoreData`'s context stacks.
///
/// - SeeAlso: `BaseStack`, `NestedStack`, `IndependentStack`
public class Roku<ContextStack: StorageModelBasedStack>: StorageModelBased {
    /// Storage model used by `CoreData` stack.
    public internal(set) var storage: StorageModel
    /// Encapsulated `CoreData` stack.
    internal private(set) var _stack: ContextStack
    /// `NSManagedObjectContext` provider.
    public internal(set) lazy var provider: Provider<NSManagedObjectContext> = {
        let provide = { () -> NSManagedObjectContext in
            let context = self._stack.createContext(.PrivateQueueConcurrencyType)
            #if os(OSX)
            // see OSX docs, it is not nil by default
            context.undoManager = nil
            #endif
            return context
        }
        
        return Provider(provider: provide)
    }()
    
    final private lazy var _saveOprations: NSOperationQueue = {
        let oq = NSOperationQueue.factory.createOprationQueue(
            name: "com.b1nary.Roku.roku_save_oq_\(unsafeAddressOf(self))"
        )
        oq.maxConcurrentOperationCount = 1
        return oq
    }()
    
    public required convenience init(storage: StorageModel) {
        let stack = ContextStack(storage: storage)
        self.init(stack: stack)
    }
    
    public init(stack: ContextStack) {
        self._stack  = stack
        self.storage = stack.storage
    }
    
    /// Call `body(c)`, where `c` is a temporary background `NSManagedObjectContext`.
    ///
    /// The temporary context is poped from the unused contexts queue.
    /// If no such context exists in queue, it is first created.
    ///
    /// - Parameters:
    ///   - body: Use the `body(c)` call to import/export data into/from context.
    ///           The save is handled by `Roku` in private background operation queue.
    ///           Don not rely on the context `c` beacause it may be reused by `Roku`.
    ///           External changes in `c` outside of `body(c)` may cause unexpected behaviours.
    ///
    ///   - save: Save operation for context `c`. `save(c)` will be executed
    ///           on a private context's background queue by `Roku`,
    ///           you don not have to call `c.performBlock` to save cotnext
    ///           in `save(c)` function. Just 'describe' how you want to save
    ///           (and handle an errors) in this function.
    public func withBackgroundContext<R>(@noescape body: NSManagedObjectContext throws -> R, save: NSManagedObjectContext -> Void = { _ = try? $0.save() }) rethrows -> R {
        // Take worker from provider
        let worker = self.provider.take()
        
        defer {
            // Capture `_provider`, save opration and worker in background queue block.
            self._saveOprations.addOperationWithBlock { [weak self, save, worker] in
                // Perform `save(c)` handled by user.
                worker.performBlockAndWait { save(worker) }
                guard let this = self else { return }
                this.provider.transmit(worker)
            }
        }
        
        return try body(worker)
    }
    
    /// Save data to persistent store.
    ///
    /// - Parameter withError: Error callback. Should return `true` iff the error
    ///                        was handled and/or `Roku` may retry saving.
    public final func persist(withError error: ErrorType -> Bool) {
        self._saveOprations.addOperationWithBlock {
            self._stack.trySave(repeatOnError: error)
        }
    }
}

public extension Roku where ContextStack: MainQueueContextStack {
    /// Main queue managed object context.
    final public var mainObjectContext: NSManagedObjectContext {
        return self._stack.mainObjectContext
    }
}
