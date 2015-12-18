//
//  StorageModel.swift
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
// Classes
import class CoreData.NSManagedObjectModel
import class CoreData.NSPersistentStoreCoordinator

/// A small layer between `Roku` framework and the external services.
///
/// Use it to initialize (or transmit existing) persistent store coordinator.
public final class StorageModel {
    /// Initialize `StorageModel`.
    ///
    /// Initializes with function that returns `NSPersistentStoreCoordinator`.
    ///
    /// - Note: You may wish to transmit existing `CoreData`'s
    ///         storage model to `Roku` with this initializer.
    ///
    /// - Parameters:
    ///   - persistentStoreCoordinator: Function, returning a persistent store
    ///                                 coordinator instance.
    ///
    ///   - beLazy:                     Lazy evaluation is used iff `true`.
    ///                                 Otherwise, the values will be computed
    ///                                 at the initialization. Defaults to `true`.
    public init(persistentStoreCoordinator: () -> NSPersistentStoreCoordinator = StorageModel.nullStore, beLazy: Bool = true) {
        self._createStore = persistentStoreCoordinator
        if beLazy == true { return }
        // Evaluate value if not lazy evaluation
        self._store = self._createStore()
    }
    
    /// Return `_NullPSC` instance.
    public static func nullStore() -> NSPersistentStoreCoordinator {
        /// `NSPersistentStoreCoordinator`. Null object pattern.
        final class _NullPSC: NSPersistentStoreCoordinator, NullObject {}
        return _NullPSC()
    }
    
    /// Return `_NullMOMD` instance.
    public static func nullModel() -> NSManagedObjectModel {
        final class _NullMOMD: NSManagedObjectModel, NullObject {}
        return _NullMOMD()
    }
    
    /// Creates persistent store coordinator (by user).
    internal private(set) var _createStore: () -> NSPersistentStoreCoordinator
    /// Private persistent store coordinator storage.
    internal private(set) var _store: NSPersistentStoreCoordinator!
    /// Initialize and/or return initialized persistent store.
    internal func _initializedStore() -> NSPersistentStoreCoordinator {
        if self._store == nil {
            self._store = self._createStore()
        }
        
        return self._store
    }
    
    // MARK: Public API
    
    /// The managed object model for the application.
    public var managedObjectModel: NSManagedObjectModel {
        get {
            if self.persistentStoreCoordinator is NullObject {
                return StorageModel.nullModel()
            }
            return self.persistentStoreCoordinator.managedObjectModel
        }
    }
    
    /// Persistent store coordinator.
    ///
    /// - Important: Check of the returned value type is recommended
    ///              before using this property. `StorageModel`
    ///              by default initializes `NullObject`
    ///              persistent store coordinator. This behaviour allows
    ///              easier internal implementaion (no more optionals :])
    ///              and easier `StorageModel` initialization.
    ///
    /// - Note:      Setting this value will force the use of lazy evaluation.
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        get {
            return self._initializedStore()
        }
        
        set {
            self._store = nil
            self._createStore = { return newValue }
        }
    }
}
