//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//	ObservableContext.swift
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

/// Objects conforming to this protocol can be observed with `ContextObserver`.
///
/// - Important: Only `NSManagedObjectContext` and its subclasses
///				 should conform to this protocol.
///				 Do not use it with other classes.
public protocol ObservableContext: class {
	/// An object that observes changes of contexts with
	/// identical parent context or persistent store coordinator.
	var observer: ContextObserver? { get }

	/// Bool value indicating whether the parent context's
	/// changes are observed or not (read-only value).
	var parentObserved: Bool { get }
	/// Bool value indicating whether the persistent store coordinator's
	/// changes are observed or not (read-only value).
	var storeObserved: Bool { get }
}

extension ObservableContext where Self: NSManagedObjectContext {
	/// Bool value indicating whether the parent context's
	/// changes are observed or not (read-only value).
	public var parentObserved: Bool {
		get {
			return self.parentContext != nil && self.observer != nil
		}
	}

	/// Bool value indicating whether the persistent store coordinator's
	/// changes are observed or not (read-only value).
	public var storeObserved: Bool {
		get {
			// Setting `parentContext` property also mutates
			// `persistentStoreCoordinator` to `parentContext.persistentStoreCoordinator`
			return self.parentContext == nil && self.persistentStoreCoordinator != nil && self.observer != nil
		}
	}
}
