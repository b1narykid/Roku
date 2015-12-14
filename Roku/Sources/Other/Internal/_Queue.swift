//
//  _Queue.swift
//  Roku
//
// Copyright (c) 2015 Ivan Trubach
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

internal enum _Queue<Element> {
    indirect case Node(Element, predecessor: _Queue<Element>)
    case Empty
}

internal extension _Queue {
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
        self = .Node(newElement, predecessor: self)
    }
    
    /// Dequeue element from `self`.
    @warn_unused_result
    internal mutating func dequeue() -> Element? {
        if case .Node(let element, predecessor: let predecessor) = self {
            self = predecessor
            return element
        } else {
            return nil
        }
    }
}

