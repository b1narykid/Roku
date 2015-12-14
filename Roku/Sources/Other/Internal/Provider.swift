//
//  Provider.swift
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

/// Object provider backed by `_Queue` stack.
internal class Provider<Object> {
    private var _objects: _Queue<Object>
    private var _provide: () -> Object
    
    internal func changeProvider(newProvider: () -> Object) {
        self._provide = newProvider
    }
    
    /// Create provider with `provier` function.
    internal init(provider: () -> Object, _ providedObjects: _Queue<Object> = .Empty) {
        self._objects = providedObjects
        self._provide = provider
    }
    
    /// Give object to the provider.
    internal func transmit(newObject: Object) {
        self._objects.enqueue(newObject)
    }
    
    /// Take provided object from provider.
    internal func take() -> Object {
        if self._objects.isEmpty {
            let newObject = self._provide()
            self.transmit(newObject)
        }
        
        return self._objects.dequeue()!
    }
}
