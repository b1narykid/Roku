//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//	ContextObserver.swift
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
import Foundation
import protocol ObjectiveC.NSObjectProtocol

internal enum ObservedStore {
	case MOC(NSManagedObjectContext)
	case PSC(NSPersistentStoreCoordinator)
	case Error
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
		guard let observedObject = self.observedObject else { return .Error }
		// Parent context should not be an `ObservableContext`
		// (unless we need to merge changes from parent context).
		if let moc = observedObject.parentContext { return .MOC(moc) }
		// iff child context, than the following is true:
		// `persistentStoreCoordinator` === `parentContext.persistentStoreCoordinator`
		if let psc = observedObject.persistentStoreCoordinator
			where observedObject.parentContext == nil { return .PSC(psc) }
		// Error... Unexpected error...
		return .Error
	}

	/// Underlying operations queue
	internal lazy var _queue: NSOperationQueue = {
		let name = "com.b1nary.Roku.roku_change_handler_\(unsafeAddressOf(self))"
		return NSOperationQueue.factory.createOprationQueue(name: name)
	}()

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

	/// Initialize observer of `managedObjectContext` context.
	///
	/// - Parameters:
	///   - managedObjectContext: `NSManagedObjectContext`
	///		conforming to `ObservableContext` which will be observed.
	///
	///   - beginObserving: Begin observing immediately iff `true`.
	///		Defaults to `true`.
	public init<Context: NSManagedObjectContext>(
		managedObjectContext pmoc: Context, beginObserving: Bool = true
	) where Context: ObservableContext {
		self.observedObject = pmoc
		if beginObserving {
			self.beginObserving()
		}
	}

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

	/// Begins observing on `notificationCenter`.
	///
	/// - Parameter notificationCenter: Notification center where `self` should
	///   begin observing context save notifications.
	internal func beginObserving(
		notificationCenter: NSNotificationCenter = .defaultCenter()
	) {
		let name = NSManagedObjectContextDidSaveNotification
		// Add observer for name using block
		self._observer = notificationCenter.addObserverForName(name,
			object: nil,
			queue: self._queue,
			usingBlock: self.saveNotification
		)
	}

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

	/// Handles context save notification `notification`.
	///
	/// - Remark: Notifications sent by `self.observedObject`.
	///
	/// - Parameters notification: Context save notification sent by object
	///   that conforms to `ObservableContext`.
	private func saveNotification(notification: NSNotification) {
		guard notification.name == NSManagedObjectContextDidSaveNotification else { return }
		// Assert that the observed object is not released. Else end observing.
		guard let obsrvd = self.observedObject else {
			return self.endObserving()
		}
		guard let sender = notification.object
			where sender is ObservableContext
			   && sender !== obsrvd else { return }
		// Check if sender is correct
		switch self.observedStore {
		// Should be context on the same 'layer'
		// or parent context (where parent is `ObservableContext`).
		case .MOC(let moc):
			guard sender.parentContext === moc
			   || (sender ===  moc && moc is ObservableContext) else { return }
		// `persistentStoreCoordinator == parentContext.persistentStoreCoordinator`.
		case .PSC(let psc):
			// Error: Ambiguous use of 'persistentStoreCoordinator'
			// guard sender.persistentStoreCoordinator === psc
			guard sender.valueForKey("persistentStoreCoordinator") === psc
			   && sender.parentContext == nil else { return }
		// Remove observer by default.
		default: return self.endObserving()
		}
		// Merge changes if all checks passed.
		obsrvd.performBlockAndWait {
			obsrvd.mergeChangesFromContextDidSaveNotification(notification)
		}
	}

//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

	/// Remove observer `self` from `notificationCenter`.
	///
	/// - Parameter notificationCenter: Notification center where `self` should
	///   end observing of context save notifications.
	internal func endObserving(notificationCenter: NSNotificationCenter = .defaultCenter()) {
		if let observer = self._observer {
			notificationCenter.removeObserver(observer)
			self._observer = nil
		}
	}

	deinit {
		self.endObserving()
	}
}
