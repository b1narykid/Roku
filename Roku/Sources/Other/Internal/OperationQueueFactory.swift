//
//  OperationQueueFactory.swift
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
import Foundation

/// Wraps the proccess of `NSOperationQueue` creation
/// for multiple platforms and OS versions.
internal class OperationQueueFactory {
    internal func createOprationQueue(name name: String? = nil, queue: dispatch_queue_t? = nil) -> NSOperationQueue {
        let oq = NSOperationQueue()
        if let name = name {
            oq.name = name
        }
        
        if #available(iOS 8.0, OSX 10.10, tvOS 9.0, *) {
            oq.underlyingQueue = queue ?? self.createDispatchQueue(identifier: name)
        }
        
        return oq
    }
    
    @available(iOS 8.0, OSX 10.10, tvOS 9.0, *)
    internal func createDispatchQueue(identifier identifier: String? = nil) -> dispatch_queue_t {
        let queueAttrs = dispatch_queue_attr_make_with_qos_class(
            DISPATCH_QUEUE_SERIAL,
            QOS_CLASS_UTILITY,
            -1
        )
        
        return dispatch_queue_create(identifier ?? "dq_by_fctry_\(unsafeAddressOf(self))", queueAttrs)

    }
}

extension NSOperationQueue {
    internal static let factory = OperationQueueFactory()
}