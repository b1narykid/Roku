//===----------------------------------------------------------------------===//
//
//  OperationQueueFactory.swift
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
import Dispatch
import Foundation

/// Encapsulates the proccess of `OperationQueue` and serial `DispatchQueue`
/// creation for multiple platforms and OS versions.
internal class QueueFactory {
	/// Create operation queue with identifier.
	///
	/// On `'iOS 8.0, OSX 10.10 < *'` optionally use custom dispatch queue.
	internal func makeOprationQueue(
		name: String? = nil, underlyingQueue queue: DispatchQueue? = nil
	) -> OperationQueue {
		let oq = OperationQueue()
		let name = name ?? "com.b1nary.Roku.factory\(unsafeAddress(of: oq))"
		oq.name = name

		if #available(iOS 8.0, OSX 10.10, /*tvOS 9.0,*/ *) {
			oq.underlyingQueue = queue ?? self.makeDispatchQueue(identifier: name)
		}

		return oq
	}

	/// Create serial dispatch queue with identifier.
	///
	/// On `'iOS 8.0, OSX 10.10 < *'` use attributes
	/// `{ DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -2 }`.
	internal func makeDispatchQueue(identifier: String) -> DispatchQueue {
		if #available(iOS 8.0, OSX 10.10, /*tvOS 9.0,*/ *) {
			// TODO: how to set DispatchQoS
			return DispatchQueue(label: identifier, attributes: [.serial, .qosUtility])
		} else {
			return DispatchQueue(label: identifier)
		}
	}
}

extension OperationQueue {
	internal static let factory = QueueFactory()
}
