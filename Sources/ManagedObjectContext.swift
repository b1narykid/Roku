//
//  ManagedObjectContext.swift
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
import CoreData

/// `NSManagedObjectContext` subclass, focused on
/// store changes observing and automatic merging.
///
/// - Note: As an additional optimization, initialization of context with
///         `.MainQueueConcurrencyType` will disable automatic merging.
///         Changes in this context are still observed by default.
///
/// - SeeAlso: [WWDC13 Session 211][WWDC Video], 28:40 (m:s).
///
/// [WWDC Video]: https://developer.apple.com/videos/play/wwdc2013-211/
public class ManagedObjectContext: NSManagedObjectContext, ObservableContext {
    /// Object, that handles observing of other contexts
    /// and merges changes into `self`.
    public internal(set) var observer: ContextObserver?

    public override var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        didSet { self.becomeObserver() }
    }

    public override var parentContext: NSManagedObjectContext? {
        didSet { self.becomeObserver() }
    }

    /// Create object, that handles observing of other contexts
    /// and merges changes into `self`. Removes the current observer.
    ///
    /// - Remark: Will not become observer iff `concurrencyType`
    ///           is `.MainQueueConcurrencyType`.
    internal func becomeObserver() {
        self.observer = nil
        if self.concurrencyType == .MainQueueConcurrencyType {
            self.observer = ContextObserver(managedObjectContext: self)
        }
    }
}
