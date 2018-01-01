//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  Roku.swift
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
import Foundation

/// Wrapper over `StorageModelContainer` stack with same API for all stack types.
///
/// Encapsulates the `CoreData` stack.
/// Provides a convenience API for the `CoreData`'s context stacks.
///
/// - SeeAlso: `StackBase`, `NestedStackBase`, `IndependentStackBase`.
public class Roku<
    ContextStack: protocol<ContextFactoryStackProtocol, StorageModelContainer>
> : RokuBase<ContextStack> {
    /// `NSManagedObjectContext` provider.
    ///
    /// - Note: Provided contexts do not have any undo manager.
    public internal(set) lazy var provider: Provider<NSManagedObjectContext> = {
        Provider {
            let context = self._stack.createContext(.PrivateQueueConcurrencyType)
            #if !os(iOS) // || !os(tvOS)
                // See OSX docs, it is not nil by default.
                // Not sure about tvOS,
                // set it to `nil` on both OSX and tvOS.
                context.undoManager = nil
            #endif
            return context
        }
    }()

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

    /// Initialize with `StorageModel` instance.
    public convenience init(
        storage: StorageModel, provider: Provider<NSManagedObjectContext>
    ) {
        let stack = ContextStack(storage: storage)
        self.init(stack: stack, provider: provider)
    }

    /// Initialize with existing stack.
    ///
    /// - Remark: Not recommended. Consider using the generic initialization,
    ///   which lets `Roku` handle the initialization and management
    ///   of the new encapsulated generic stack.
    ///   Use this `init` only if the full control over the stack is needed
    public init(
        stack: ContextStack, provider: Provider<NSManagedObjectContext>
    ) {
        super.init(stack: stack)
        self.provider = provider
    }

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

    /// Call `body(c)`, where `c` is a temporary background managed object context.
    ///
    /// The temporary context is poped from queue of unused contexts.
    /// If no such context exists in queue, it is first created.
    ///
    /// - Remark: `save(c)` is called to save context
    ///   even if the `body(c)` throws an error.
    ///
    /// - Parameters:
    ///   - body: Use the `body(c)` call to import/export data into/from context.
    ///     The save is handled by `Roku` in private background operation queue.
    ///     Don not rely on the context `c` beacause it may be reused by `Roku`.
    ///     External changes in `c` outside of `body(c)` may cause unexpected behaviours.
    ///
    ///   - save: Save operation for context `c`. `save(c)` will be executed
    ///     on a private context's background queue by `Roku`,
    ///     you don not have to call `c.performBlock` to save cotnext
    ///     in `save(c)` function. Just 'describe' how you want to save
    ///     (and handle an errors) in this function.
    public final func withBackgroundContext<R>(
        @noescape body: NSManagedObjectContext throws -> R,
        save: NSManagedObjectContext -> Void = performSave
    ) rethrows -> R {
        // Take worker from provider
        let worker = self.provider.take()

        defer {
            self._saves.addOperationWithBlock { [weak self] in
                withExtendedLifetime(worker) {
                    // Perform `save(c)` handled by user.
                    worker.performBlockAndWait { save(worker) }
                    guard let this = self else { return }
                    this.provider.transmit(worker)
                }
            }
        }

        return try body(worker)
    }
}

/// Perfrom save if `context` has changes.
private func performSave(context: NSManagedObjectContext) {
    if context.hasChanges {
        do {
            try context.save()
        } catch {
        }
    }
}
