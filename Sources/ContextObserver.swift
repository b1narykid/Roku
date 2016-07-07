//===----------------------------------------------------------------------===//
//
//  ContextObserver.swift
//  Roku
//
// Copyright (c) 2016 Ivan Trubach
//
//===----------------------------------------------------------------------===//
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
//===----------------------------------------------------------------------===//

import Swift
import CoreData
import Foundation
import protocol ObjectiveC.NSObjectProtocol

internal enum ObservedStore {
	case moc(NSManagedObjectContext)
	case psc(NSPersistentStoreCoordinator)
	case error
}

/// An observer for `NSManagedObjectContext` context
/// where context is `ObservableContext`.
///
/// Merges all changes in `NSManagedObjectContextDidSaveNotification`
/// notification from `ObservableContext` contexts to `observedObject`.
///
/// - Remark: To prevent unexpected behaviour in other contexts,
///   `ContextObserver` merges changes only from `NSManagedObjectContext`
///   instances that conform to `ObservableContext` protocol.
public class ContextObserver {
	/// Observed object.
	///
	/// - Remark: Weak reference. Receiving a notification when
	///   the object, pointed by this reference is `nil`
	///   will cause the removal of notification observer.
	public internal(set) weak var observedObject: NSManagedObjectContext? {
		willSet {
			guard newValue is ObservableContext else {
				fatalError("observedObject should be ObservableContext")
			}
		}
	}

	/// An opaque object to act as the observer.
	internal private(set) var _observer: NSObjectProtocol?
	/// Max number of concurrent change merges.
	internal private(set) var maxConcurrentMergesCount: Int {
		get { return self._queue.maxConcurrentOperationCount }
		set { self._queue.maxConcurrentOperationCount = newValue }
	}

	/// Observed store type. Read-only.
	///
	/// - Warning: Does not handle error.
	internal var observedStore: ObservedStore {
		guard let observedObject = self.observedObject else { return .error }
		// Parent context should not be an `ObservableContext`
		// (unless we need to merge changes from parent context).
		if let moc = observedObject.parent { return .moc(moc) }
		// iff child context, than the following is true:
		// `persistentStoreCoordinator` === `parentContext.persistentStoreCoordinator`
		if let psc = observedObject.persistentStoreCoordinator
			where observedObject.parent == nil { return .psc(psc) }
		// Error... Unexpected error...
		return .error
	}

	/// Underlying operations queue
	internal lazy var _queue: OperationQueue = {
		let name = "com.b1nary.Roku.change_handler_\(unsafeAddress(of: self))"
		return OperationQueue.factory.makeOprationQueue(name: name)
	}()

	//===--------------------------------------------------------------------===//

	/// Initialize observer of `managedObjectContext` context.
	///
	/// - Parameters:
	///   - managedObjectContext: `NSManagedObjectContext`
	///     conforming to `ObservableContext` which will be observed.
	///
	///   - beginObserving: Begin observing immediately iff `true`.
	///     Defaults to `true`.
	public init<Context: NSManagedObjectContext where Context: ObservableContext>(
		managedObjectContext pmoc: Context, beginObserving: Bool = true
	) {
		self.observedObject = pmoc
		if beginObserving {
			self.beginObserving()
		}
	}

	//===--------------------------------------------------------------------===//

	/// Begins observing on `notificationCenter`.
	///
	/// - Parameter notificationCenter: Notification center where `self` should
	///   begin observing context save notifications.
	internal func beginObserving(
		_ notificationCenter: NotificationCenter = .default()
	) {
		let name = NSNotification.Name.NSManagedObjectContextDidSave
		// Add observer for name using block
		self._observer = notificationCenter.addObserver(
			forName: name,
			object: nil,
			queue: self._queue,
			using: self.saveNotification)
	}

	//===--------------------------------------------------------------------===//

	/// Handles context save notification `notification`.
	///
	/// - Remark: Notifications sent by `self.observedObject`.
	///
	/// - Parameters notification: Context save notification sent by object
	///   that conforms to `ObservableContext`.
	private func saveNotification(_ notification: Notification) {
		guard notification.name == NSNotification.Name.NSManagedObjectContextDidSave else { return }
		// Assert that the observed object is not released. Else end observing.
		guard let observed = self.observedObject else {
			return self.endObserving()
		}
		guard let sender = notification.object
			where sender is ObservableContext
				&& sender !== observed else { return }
		// Check if sender is correct
		switch self.observedStore {
		// Should be context on the same 'layer'
		// or parent context (where parent is `ObservableContext`).
		case .moc(let moc):
			guard sender.parent === moc || (sender ===  moc && moc is ObservableContext)
				else { return }
		// `persistentStoreCoordinator == parentContext.persistentStoreCoordinator`.
		case .psc(let psc):
			// Error: Ambiguous use of 'persistentStoreCoordinator'
			// guard sender.persistentStoreCoordinator === psc
			guard sender.value(forKey: "persistentStoreCoordinator") === psc
				&& sender.parent == nil else { return }
		// Remove observer by default.
		default: return self.endObserving()
		}
		// Merge changes if all checks passed.
		observed.performAndWait {
			observed.mergeChanges(fromContextDidSave: notification)
		}
	}

	//===--------------------------------------------------------------------===//

	/// Remove observer `self` from `notificationCenter`.
	///
	/// - Parameter notificationCenter: Notification center where `self` should
	///   end observing of context save notifications.
	internal func endObserving(_ notificationCenter: NotificationCenter = .default()) {
		if let observer = self._observer {
			notificationCenter.removeObserver(observer)
			self._observer = nil
		}
	}

	deinit {
		self.endObserving()
	}
}
