//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  RokuBase.swift
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

/// Wrapper over `StorageModelBased` stack.
///
/// Contains generic features and implementation details of `Roku`.
public class RokuBase<
    ContextStack: protocol<CoreProtocol, StorageModelBased>
> : StorageModelBased {
    /// Storage model used by `CoreData` stack.
    public var storage: StorageModel { return self._stack.storage }
    /// Encapsulated `CoreData` stack.
    internal var _stack: ContextStack
    /// Save operations queue.
    ///
    /// Synchronous (maxConcurrentOperationCount = 1).
    internal final private(set) lazy var _saves: NSOperationQueue = {
        let oq = NSOperationQueue.factory.createOprationQueue(
            name: "com.b1nary.Roku.roku_save_oq_\(unsafeAddressOf(self))"
        )
        // Required for synchronous saves (not on main queue)
        oq.maxConcurrentOperationCount = 1
        return oq
    }()

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

    /// Initialize with `StorageModel` instance.
    public convenience required init(storage: StorageModel) {
        let stack = ContextStack(storage: storage)
        self.init(stack: stack)
    }

    /// Initialize with existing stack.
    ///
    /// - Remark: Not recommended. Consider using the generic initialization,
    ///   which lets `Roku` handle the initialization and management
    ///   of the new encapsulated generic stack.
    ///   Use this `init` only if the full control over the stack is needed
    public init(stack: ContextStack) {
        self._stack = stack
    }

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

    /// Call `body(c)`, where `c` is an incapsulated generic stack.
    public func withUnderlyingStack<Result>(
        @noescape body: (inout ContextStack) throws -> Result
        ) rethrows -> Result {
            return try body(&self._stack)
    }
}

//===–––––––––––––––––––––––––––– SavableStackProtocol ––––––––––––––––––––––––––––===//

extension RokuBase where ContextStack: SavableStackProtocol {
    /// Save data to persistent store.
    ///
    /// - Parameter stopOnError: Error callback.
    ///   Return `true` iff `Roku` should retry saving.
    public final func persist(stopOnError error: ErrorType -> Bool) {
        self._saves.addOperationWithBlock {
            self._stack.trySave(stopOnError: error)
        }
    }
}

//===–––––––––––––––––––––––––––– StackCoreProtocol –––––––––––––––––––––––––––===//

extension RokuBase where ContextStack: StackCoreProtocol {
    /// Master managed object context.
    public final var masterObjectContext: NSManagedObjectContext {
        return self._stack.masterObjectContext
    }
}

//===––––––––––––––––––––––– MainQueueStackProtocol –––––––––––––––––––––––===//

extension RokuBase where ContextStack: MainQueueStackProtocol {
    /// Main queue managed object context.
    public final var mainObjectContext: NSManagedObjectContext {
        return self._stack.mainObjectContext
    }
}
