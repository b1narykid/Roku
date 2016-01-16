//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  SavableStack.swift
//  Roku
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

/// A stack that can save its managed object contexts.
public protocol SavableStack: CoreStack {
    /// Save changes in contexts implemented in this template
    /// to the persistent store.
    ///
    /// - Parameter stopOnError: Callback closure. Informs caller about the error.
    ///   Should return `true` if can retry context save.
    ///   Otherwise, return false or you will get an infinite save attempts.
    mutating func trySave(stopOnError error: ErrorType -> Bool)
}

//===–––––––––––––––––––––––––––––– Internal ––––––––––––––––––––––––––––––===//

internal extension SavableStack {
    /// Try saving context.
    ///
    /// Provides an internal synchrounous context saving functionality
    /// with error callback.
    internal mutating func trySaveContext(
        context: NSManagedObjectContext, callback: ErrorType -> Bool
    ) {
        context.performBlockAndWait {
            do {
                try context.save()
            } catch {
                // Let the user handle an error.
                guard callback(error) else { return }
                // Retrying save operation.
                self.trySaveContext(context, callback: callback)
            }
        }
    }
}
