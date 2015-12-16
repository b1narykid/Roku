# Roku

> Warning:
> This project is currently in development.

CoreData's concurrent stacks made easy.

### `StorageModel`
A small layer between `Roku` framework and the external services.

> `StorageModel` API is currently in development.

##### Usage

Initializing storage model (recomended).
```swift
func createPersistentStore() -> NSPersistentStoreCoordinator {
    // Create and return persistent store coordinator
}

let storage = StorageModel(persistentStoreCoordinator: createPersistentStore)
```

Overriding lazy initialization.
```swift
// By default, `StorageModel` uses lazy initialization of its values.
let dontBeLazy = false
let storage = StorageModel(persistentStoreCoordinator: createPersistentStore, lazyEvaluation: dontBeLazy)
```

###### Error handling

`Roku` relies on existence of persistent store coordinator.
Writing a lot of `guard` and `if`-`else` conditions and then letting the user
to handle the error was not the best solution.

`StorageModel`, by default initializes its properties to internal subclasses,
conforming to `NullObject` protocol.

You can get instances of those internal subclasses by calling
```swift
StorageModel.nullStore() // -> NSPersistentStoreCoordinator, NullObject
```
or
```swift
StorageModel.nullModel() // -> NSManagedObjectModel, NullObject
```

Example of handling errors on `StorageModel` initialization.
```swift
let storage = StorageModel()

// Initialization of persistent store coordinator...
// Don't assign any value to `persistentStoreCoordinator` if an error occurs

if storage.persistentStoreCoordinator is NullObject {
    // Persistent store coordinator was not initialized by user
    // Handle an error
}
```

##### Related protocols

###### `StorageModelConvertible`
Describes an object, that could be initialized with `StorageModel` instance.

###### `StorageModelBased`
Describes an object, that could be initialized with `StorageModel` instance
and its behavior relies on storage model.

###### `StorageModelBasedStack`
Describes a contexts stack that could be initialized with `StorageModel`
instance and its behavior relies on storage model.
Type alias of two protocols:
`BaseStackTemplate`
`StorageModelBased`
All default implementations conform to this protocol.
Your custom implementations have to conform to this protocol
to be used with `Roku` class.

## TODO
- [x] Implement observable NSManagedObjectContext.
- [x] Implement templates and default implementations.
- [ ] Implement all functionality of `Roku` class.
- [ ] Finish writing README.md file.
- [ ] Add examples of custom stack templates and implementations.
- [ ] Feature: implement manager for stack with multiple persistent store coordinators.
- [ ] Write unit tests.

## License

```
The MIT License (MIT)

Copyright © 2015 Ivan Trubach

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
