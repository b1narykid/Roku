//===----------------------------------------------------------------------===//
//
//  Queue.swift
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

#if !swift(>=3)
	public typealias Sequence = Swift.Sequence
#endif

/// A queue data structure type that can be iterated with a `for`...`in` loop.
public protocol QueueSequence: Sequence {
	/// Enqueue element into `self`.
	mutating func enqueue(_ newElement: Self.Iterator.Element)
	/// Dequeue element from `self`.
	mutating func dequeue() -> Self.Iterator.Element?
}

extension Array: QueueSequence {
	/// Enqueue element into `self`.
	public mutating func enqueue(_ newElement: Array.Iterator.Element) {
		self.append(newElement)
	}

	/// Dequeue element from `self`.
	public mutating func dequeue() -> Array.Iterator.Element? {
		return self.popLast()
	}
}
