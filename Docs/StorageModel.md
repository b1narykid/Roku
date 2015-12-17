# Roku

CoreData's concurrent stacks made easy.

## `StorageModel`

> `StorageModel` API is currently in development.
> There are more feature to be added soon.

A small layer between `Roku` framework and the external services.

### Error handling

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

#### Usage

##### Overriding lazy initialization.

By default, `StorageModel` initializes its values lazily.

```swift
let dontBeLazy = false
let storage = StorageModel(persistentStoreCoordinator: createPersistentStore, beLazy: dontBeLazy)
```

##### Initializing storage model (recomended way).
```swift
func createPersistentStore() -> NSPersistentStoreCoordinator {
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    // Create persistent store coordinator
    // ...
    if let error = error {
        // Handle error.
        // And return `NullObject`.
        return StorageModel.nullStore()
    }
    // Return new persistent store coordinator
    return persistentStoreCoordinator
}

let storage = StorageModel(persistentStoreCoordinator: createPersistentStore)
```

#### Related protocols

##### `StorageModelConvertible`
Describes an object, that could be initialized with `StorageModel` instance.

##### `StorageModelBased`
Describes an object, that could be initialized with `StorageModel` instance
and its behavior relies on storage model.

##### `StorageModelBasedStack`
Describes a contexts stack that could be initialized with `StorageModel`
instance and its behavior relies on storage model.
Type alias of two protocols:
`BaseStackTemplate`
`StorageModelBased`
All default implementations conform to this protocol.
Your custom implementations have to conform to this protocol
to be used with `Roku` class.
