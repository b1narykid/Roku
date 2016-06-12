//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//	IndependentStackBase.swift
//	Roku
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

/// Concurrent stack implementation with independent managed object contexts.
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
/// - SeeAlso: `IndependentStackProtocol`, `StackBase`, `NestedStackBase`
public final class IndependentStackBase: StackBase, IndependentStackProtocol {
	/// Main managed object context.
	///
	/// - Note: Independent and works with `self.persistentStoreCoordinator`.
	///   Managed object context has main queue concurrency type.
	public internal(set) lazy var mainObjectContext: NSManagedObjectContext = {
		let context = ManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		context.persistentStoreCoordinator = self.storage.persistentStoreCoordinator
		return context
	}()
}
