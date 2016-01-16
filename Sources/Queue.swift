//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//  Queue.swift
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
//
//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//

import Swift

/// A queue data structure type that can be iterated with a `for`...`in` loop.
///
/// `QueueSequenceType` makes no requirement on conforming types regarding
/// whether they will be destructively "consumed" by iteration.  To
/// ensure non-destructive iteration, constrain your *sequence* to
/// `CollectionType`.
///
/// As a consequence, it is not possible to run multiple `for` loops
/// on a sequence to "resume" iteration:
///
///     for element in sequence {
///       if ... some condition { break }
///     }
///
///     for element in sequence {
///       // Not guaranteed to continue from the next element.
///     }
///
/// `QueueSequenceType` makes no requirement about the behavior in that
/// case.  It is not correct to assume that a sequence will either be
/// "consumable" and will resume iteration, or that a sequence is a
/// collection and will restart iteration from the first element.
/// A conforming sequence that is not a collection is allowed to
/// produce an arbitrary sequence of elements from the second generator.
public protocol QueueSequenceType: SequenceType {
    /// Enqueue element into `self`.
    mutating func enqueue(newElement: Self.Generator.Element)
    /// Dequeue element from `self`.
    mutating func dequeue() -> Self.Generator.Element?
}

extension Array: QueueSequenceType {
    /// Enqueue element into `self`.
    public mutating func enqueue(newElement: Array.Generator.Element) {
        self.append(newElement)
    }

    /// Dequeue element from `self`.
    public mutating func dequeue() -> Array.Generator.Element? {
        return self.popLast()
    }
}
