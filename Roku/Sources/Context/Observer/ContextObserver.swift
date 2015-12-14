//
//  ContextObserver.swift
//  Roku
//
//  Created by Ivan Trubach on 07.12.15.
//  Copyright © 2015 Ivan Trubach. All rights reserved.
//

import Swift
import CoreData

private enum ObservedParentStore {
    case MOC(NSManagedObjectContext)
    case PSC(NSPersistentStoreCoordinator)
    /// Error: No storage
    case Error
}

/// An observer for `NSManagedObjectContext` context
/// where context is `ObservableContext`.
///
/// Merges all changes with `NSManagedObjectContextDidSaveNotification`
/// notification from `ObservableContext` contexts to `observedObject`.
public class ContextObserver {
    /// Observed object.
    ///
    /// - Note: Weak reference. Receiving a notification when 
    ///         the object, pointed by reference is `nil`
    public internal(set) weak var observedObject: NSManagedObjectContext?
    
    // MARK: Multithreading
    
    /// Asynchronous changes merging
    public var asynchronous: Bool {
        willSet {
            let max = NSOperationQueueDefaultMaxConcurrentOperationCount
            self._queue.maxConcurrentOperationCount = newValue ? max : 1
        }
    }
    
    /// Underlying operations queue
    internal lazy var _queue: NSOperationQueue = {
        let name = "com.b1nary.Roku.roku_change_handler_\(unsafeAddressOf(self))"
        return NSOperationQueue.factory.createOprationQueue(name: name)
    }()
    
    
    /// Observer for `managedObjectContext` context.
    ///
    /// Starts observing and merging changes
    public init<Context: NSManagedObjectContext where Context: ObservableContext>(
        managedObjectContext pmoc: Context,
        asynchronous: Bool = false) {
        self.observedObject = pmoc
        self.asynchronous = asynchronous
        self.beginObserving()
    }
    
    // MARK: Private
    
    private var observedStore: ObservedParentStore {
        get {
            guard let observedObject = self.observedObject else {
                return .Error
            }
            
            // Initilizing context with persistent as a child context 
            // also initializes its `persistentStoreCoordinator` (or it is getter).
            if let moc = observedObject.parentContext where moc is ObservableContext {
                return .MOC(moc)
            }
            
            if let psc = observedObject.persistentStoreCoordinator where observedObject.parentContext == nil {
                return .PSC(psc)
            }
            
            return .Error
        }
    }
    
    private var _observer: NSObjectProtocol?
    
    private func beginObserving(notificationCenter: NSNotificationCenter = .defaultCenter()) {
        let name = NSManagedObjectContextDidSaveNotification
        // Add observer for name using block
        notificationCenter.addObserverForName(name,
            object: nil,
            queue: self._queue,
            usingBlock: self.saveNotification
        )
    }
    
    private func saveNotification(notific: NSNotification) {
        guard notific.name == NSManagedObjectContextDidSaveNotification else { return }
        // Assert that the observed object is not released.
        guard let obj = self.observedObject else { return self.endObserving() }
        guard let sender = notific.object where sender is ObservableContext && sender !== obj else { return }
        
        switch self.observedStore {
        case .MOC(let moc):
            // Context on the same 'layer' or parent context.
            guard sender.parentContext === moc || sender ===  moc else { break }
        case .PSC(let psc):
            // `persistentStoreCoordinator == parentContext.persistentStoreCoordinator`
            guard sender.persistentStoreCoordinator === psc
                && sender.parentContext == nil else { break }
        default: return self.endObserving()
        }
        
        // Anyway, there is no need in `performBlock()`
        // if we are on background queue.
        obj.performBlockAndWait {
            obj.mergeChangesFromContextDidSaveNotification(notific)
        }
    }
    
    /// Remove observer
    private func endObserving(notificationCenter: NSNotificationCenter = .defaultCenter()) {
        guard let observer = self._observer else { return }
        notificationCenter.removeObserver(observer)
    }

    deinit {
        self.endObserving()
    }
}
