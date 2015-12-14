//
//  StorageModel.swift
//  Roku
//
//  Created by Ivan Trubach on 15.11.15.
//  Copyright © 2015 Ivan Trubach. All rights reserved.
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
import CoreData

/// Basic layer between `Roku` framework and the external services.
///
/// Wrapper of `CoreData`'s storage model classic implementation.
public class StorageModel {
    /// Initialize `StorageModel`.
    ///
    /// Initializes with `NSManagedObjectModel` (optional) and `NSPersistentStoreCoordinator`.
    ///
    /// - Note: You may want to transmit your `CoreData`'s
    ///         storage model to `Roku` with this initializer.
    ///
    /// - Parameter managedObjectModel:         Managed object model instance.
    ///                                         This object has a default `NullObject` value.
    ///                                         You may ignore this parameter iff
    ///                                         `persistentStoreCoordinator().managedObjectModel` 
    ///                                         is a correct value. `StorageModel` will use either
    ///                                         the passed parameter value (if not `NullObject`)
    ///                                         or `persistentStoreCoordinator.managedObjectModel`.
    ///
    /// - Parameter persistentStoreCoordinator: Persistent store coordinator instance.
    ///                                         You may either transmit an persistent store coordinator
    ///                                         to the `Roku` framework or create a new one in a closure.
    ///
    /// - Parameter lazyEvaluation:             Uses lazy evaluation iff `true`. Otherwise, iff `false`,
    ///                                         the values will be computed at the initialization.
    ///                                         Default value is `true`.
    public init(
        managedObjectModel         model: () -> NSManagedObjectModel = { return _NullManagedObjectModel() },
        persistentStoreCoordinator store: () -> NSPersistentStoreCoordinator,
        lazyEvaluation beLazy: Bool = true) {
        // Set new values initializer
        self._createModel = model
        self._createStore = store
        // Evaluate values if not lazy evaluation
        guard beLazy == false else { return }
        
        self._store = self._initializedStore()
        self._model = self._initializedModel()
    }
    
    // MARK: Private API
    
    /// `NSPersistentStoreCoordinator`. Null object pattern.
    private final class _NullPersistentStoreCoordinator: NSPersistentStoreCoordinator, NullObject {}
    /// `NSManagedObjectModel`. Null object pattern.
    private final class _NullManagedObjectModel: NSManagedObjectModel, NullObject {}
    
    /// Creates managed object model (by user).
    private var _createModel: () -> NSManagedObjectModel
    /// Creates persistent store coordinator (by user).
    private var _createStore: () -> NSPersistentStoreCoordinator
    /// Private managed object context storage.
    internal var _model: NSManagedObjectModel!
    /// Private persistent store coordinator storage.
    internal var _store: NSPersistentStoreCoordinator!
    /// Initialize and/or return initialized managed object model.
    private func _initializedModel() -> NSManagedObjectModel {
        if self._model == nil {
            self._model = self._createModel()
        }
        
        if self._model is NullObject || self._model == nil {
            self._model = self.persistentStoreCoordinator.managedObjectModel
        }
        
        return self._model
    }
    /// Initialize and/or return initialized persistent store.
    private func _initializedStore() -> NSPersistentStoreCoordinator {
        if self._store == nil {
            self._store = self._createStore()
        }
        
        // Check whether it is `NullObject` or not.
        if self._store is NullObject || self._store == nil {
            // _NullPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            self._store = _NullPersistentStoreCoordinator()
        }
        
        return self._store
    }
    
    // MARK: Public API
    
    /// The managed object model for the application.
    public var managedObjectModel: NSManagedObjectModel {
        get {
            return self._initializedModel()
        }
    }
    
    /// Persistent store coordinator.
    ///
    /// - Important: Check of the returned value type is required
    ///              before using this property. `StorageModel`
    ///              by default initializes in-memory store with
    ///              `NullObject`
    ///              persistent store coordinator type. This behaviour 
    ///              allows easier internal implementaion (less checks)
    ///              and less failable `Roku` initialization because 
    ///              user has the ability to handle the error (and retry).
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        get {
            return self._initializedStore()
        }
    }
    
    /// Resets the current state of `self` with specified parameter.
    ///
    /// Useful for reusing one StorageModel after handling an external
    /// error which could not be detected by the storage model.
    public func resetModelWith(
        @autoclosure(escaping) managedObjectModel: () -> NSManagedObjectModel = _NullManagedObjectModel(),
        @autoclosure(escaping) persistentStoreCoordinator: () -> NSPersistentStoreCoordinator,
        lazyEvaluation beLazy: Bool = true) {
            // Reset previous values
            self._model = nil
            self._store = nil
            // Set new values initializer
            self._createModel = managedObjectModel
            self._createStore = persistentStoreCoordinator
            // Evaluate values if not lazy evaluation
            guard beLazy == false else { return }
            
            self._store = self._initializedStore()
            self._model = self._initializedModel()
    }
}
