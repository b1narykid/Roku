> Warning:
> This project no longer maintained.  Consider using [NSPersistentContainer].

# Roku ([六](https://en.wiktionary.org/wiki/六#Numeral))

CoreData's concurrent stacks made easy.

> Inspired by [Concurrent Core Data Stacks] article,
> [WWDC2013 Session 211] and [Seru] CoreData stack by [kostiakoval].

## Usage

> Note: `Roku` has a set of flexible protocols for building stacks
> but I have not documented the usage of them yet.

```swift
import Roku
```

Initialize `StorageModel` with a function that creates a new coordinator:

```swift
func newPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
    // Create and return new persistent store coordinator
}

let storage = StorageModel(persistentStoreCoordinator: newPersistentStoreCoordinator())
```

or migrate an existing persistent store coordinator.

```swift
let storage = StorageModel(persistentStoreCoordinator: oldPersistentStoreCoordinator)
```

--------------------------------------------------------------------------------

Initialize `Roku` stack with a base stack:

```swift
let baseStack = Roku<StackBase>(storage: storage)
```

or with a nested stack...

```swift
let nestedStack = Roku<NestedStackBase>(storage: storage)
```

or with an independent stack...

```swift
let independentStack = Roku<IndependentStackBase>(storage: storage)
```

or with a custom stack that conforms to `StackProtocol` and `StorageModelContainer` protocols.

```swift
let myAwesomeStack = Roku<AwesomeStack>(storage: storage)
```

--------------------------------------------------------------------------------

Enjoy `Roku`'s features :tada:

```swift
myStack.withBackgroundContext { context in
    // Do heavy import operations on the background context
}

myStack.persist { error -> Bool in
    // Handle an error

    // If error was successfully handled,
    // `Roku` will repeat save.
    return errorHandled && shouldRepeatSave
}

// Managed object context with main queue concurrency type
myStack.mainObjectContext

// Get `StorageModel` from encapsulated stack
let storage = myStack.withUnderlyingStack { (inout stack: ContextStack) in
    return stack.storage
}
```

--------------------------------------------------------------------------------

## TODO
- [x] Implement observable [NSManagedObjectContext].
- [x] Implement templates and default implementations.
- [x] Implement all functionality of `Roku` class.
- [ ] Finish writing README.md file.
- [ ] Add examples of custom stack templates and implementations.
- [ ] Feature: implement manager for stack with multiple persistent store coordinators.
- [ ] Continuous integration.

## License

Available under the MIT license.  See [license file](LICENSE.md) for more info.

[@kostiakoval]:    https://github.com/kostiakoval
[Seru]:            https://github.com/kostiakoval/Seru

[Concurrent Core Data Stacks]: http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/
[WWDC2013 Session 211]:        https://developer.apple.com/videos/play/wwdc2013-211/

[NSManagedObjectContext]: https://developer.apple.com/documentation/CoreData/NSManagedObjectContext
[NSPersistentContainer]:  https://developer.apple.com/documentation/CoreData/NSPersistentContainer
