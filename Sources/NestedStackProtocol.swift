//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//	NestedStackProtocol.swift
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

/// Concurrent stack template with nested managed object contexts.
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
/// - SeeAlso:	 `NestedStackBase`, `StackProtocol`, `IndependentStackProtocol`
public protocol NestedStackProtocol: StackCoreProtocol, MainQueueStackProtocol {
	/// Root managed object context.
	///
	/// - Note: Should be with `PrivateQueueConcurrencyType` concurrency type.
	var masterObjectContext: NSManagedObjectContext { get }
	/// Main managed object context.
	///
	/// - Note: Should be with `.MainQueueConcurrencyType` and
	///			child context of `self.masterObjectContext`.
	var mainObjectContext: NSManagedObjectContext { get }
}

extension NestedStackProtocol where Self: SavableStackProtocol {
	/// Save changes in all contexts implemented in this template
	/// to the persistent store.
	///
	/// - Note: Worker contexts are not saved.
	///
	/// - Parameter stopOnError: Callback closure. Informs caller about the error.
	///   Should return `true` if can retry context save.
	///   Otherwise, return false or you will get an infinite save attempts.
	public mutating func trySave(
		repeatOnError error: ErrorType -> Bool = { _ in return false }
	) {
		// Save second layer.
		self.trySaveContext(self.mainObjectContext, callback: error)
		// Save first layer.
		self.trySaveContext(self.masterObjectContext, callback: error)
	}
}

extension NestedStackProtocol where Self: ContextFactoryStackProtocol {
	/// Create new context for this template.
	///
	/// - Parameter concurrencyType: Concurrency type of managed object context.
	///   Defaults to `PrivateQueueConcurrencyType`.
	///
	/// - Returns: New `ManagedObjectContext` instance as
	///   a child of `self.mainObjectContext`.
	public mutating func createContext(
		concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType
	) -> NSManagedObjectContext {
		let context = ManagedObjectContext(concurrencyType: concurrencyType)
		context.parentContext = self.mainObjectContext
		return context
	}
}
