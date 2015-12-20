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

import Swift

internal indirect enum Queue<Element> {
    case Node(Element, predecessor: Queue<Element>)
    case Empty
}

internal extension Queue {
    internal var isEmpty: Bool {
        switch self {
        case .Empty: return true
        default: return false
        }
    }

    internal var isEnd: Bool {
        switch self {
        case .Node(_, predecessor: let predecessor) where predecessor.isEmpty:
            return true
        default:
            return false
        }
    }

    /// Enqueue element to `self`.
    internal mutating func enqueue(newElement: Element) {
        self = self.enqueuing(newElement)
    }

    /// Dequeue element from `self`.
    @warn_unused_result
    internal mutating func dequeue() -> Element? {
        switch self {
        case .Node(let element, predecessor: let predecessor):
            self = predecessor
            return element
        case .Empty:
            return nil
        }
    }

    /// Enqueue element to copy of `self`.
    internal nonmutating func enqueuing(newElement: Element) -> Queue<Element> {
        return .Node(newElement, predecessor: self)
    }

    /// Dequeue element from `self` nondestructively.
    internal nonmutating func dequeuing() -> Element? {
        switch self {
        case .Node(let element, predecessor: _):
            return element
        case .Empty:
            return nil
        }
    }
}

extension Queue: SequenceType {
    internal func generate() -> AnyGenerator<Element> {
        var queue = self
        return anyGenerator {
            return queue.dequeue()
        }
    }
}
