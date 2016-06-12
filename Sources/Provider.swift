//===––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––===//
//
//	Provider.swift
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

/// Object provider.
///
/// Stores provided objects in generic queue.
public class Provider<Object> {
	internal typealias Queue = Array<Object> // QueueSequence

	internal private(set) var _objects: Queue
	internal private(set) var _provide: () -> Object

	/// Provide a new object.
	public func provide() -> Object {
		return self._provide()
	}

	/// Transmit ('give') an object to the provider.
	public func transmit(newObject: Object) {
		self._objects.enqueue(newObject)
	}

	/// Take provided object from provider.
	public func take() -> Object {
		return self._objects.dequeue() ?? self.provide()
	}

	/// Create provider with `provider` function.
	public convenience required init(providing: () -> Object) {
		self.init(providing: providing, Queue())
	}

	/// Create provider with `provider` function and queue of existing object.
	internal init(providing: () -> Object, _ providedObjects: Queue) {
		self._objects = Queue()
		self._provide = providing
	}
}
