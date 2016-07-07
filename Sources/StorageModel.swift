//===----------------------------------------------------------------------===//
//
//  StorageModel.swift
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

/// A small layer between `Roku` framework and the external services.
///
/// Use it to initialize (or transmit existing) persistent store coordinator.
public final class StorageModel {

	/// The managed object model for the application.
	public var managedObjectModel: NSManagedObjectModel {
		get {
			return self.persistentStoreCoordinator.managedObjectModel
		}
	}

	/// Persistent store coordinator.
	public var persistentStoreCoordinator: NSPersistentStoreCoordinator

	//===--------------------------------------------------------------------===//

	/// Initialize `StorageModel`.
	///
	/// Initializes `self` with `NSPersistentStoreCoordinator`.
	///
	/// - Note: You may wish to transmit existing `CoreData`'s
	///   storage model to `Roku` with this initializer.
	///
	/// - Parameters:
	///   - persistentStoreCoordinator: A persistent store coordinator instance.
	public init(
		persistentStoreCoordinator: NSPersistentStoreCoordinator
	) {
		self.persistentStoreCoordinator = persistentStoreCoordinator
	}

	//===--------------------------------------------------------------------===//
	// - MARK: Deprecated interface
	//===--------------------------------------------------------------------===//
	// Obsoleted

	@available(*,
		deprecated: 0.3.0,
		obsoleted:  0.3.0,
		message:    "'Lazy' behaviour was deprecated.",
		renamed:    "StorageModel.init(persistentStoreCoordinator:)")
	public init(
		persistentStoreCoordinator:
			@autoclosure(escaping) () -> NSPersistentStoreCoordinator,
		beLazy: Bool
	) {
		fatalError("\(#function) was deprecated.")
	}

	@available(*,
		deprecated: 0.3.0,
		obsoleted:  0.3.0,
		message:    "'Lazy' behaviour was deprecated.",
		renamed:    "persistentStoreCoordinator")
	public func change(
		persistentStoreCoordinator:
			@autoclosure(escaping) () -> NSPersistentStoreCoordinator,
		beLazy: Bool = true
	) {
		fatalError("\(#function) was deprecated.")
	}
}
