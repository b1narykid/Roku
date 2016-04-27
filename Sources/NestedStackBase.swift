//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  NestedStackBase.swift
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

/// Concurrent stack implementation with nested managed object contexts.
///
/// This stack consists of three layers.
/// First layer is a writer (master) managed object context
/// with the private concurrency type (operating on a background thread).
/// Second layer consists of a main thread’s
/// managed object context as a child of this master context.
/// Third layer consists of one or multiple worker contexts
/// as children of the main context in the private queue.
///
/// - Remark: In this setup the worker contexts on
///   the third layer are used to import the data.
///
/// - Note: There may be multiple contexts on the second
///   and third layers and worker contexts on the second layer.
///
/// - SeeAlso: `NestedStackProtocol`, `StackBase`, `IndependentStackBase`
public final class NestedStackBase: StackBase, NestedStackProtocol {
    /// Main managed object context.
    ///
    /// - Note: `self.masterObjectContext` is parent of `self.mainObjectContext`.
    ///   Managed object context has main queue concurrency type.
    public internal(set) lazy var mainObjectContext: NSManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = self.masterObjectContext
        return context
    }()
}
