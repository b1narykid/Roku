> Warning:
> This project is currently in development.

# Roku ([六](https://en.wiktionary.org/wiki/六#Numeral))

CoreData's concurrent stacks made easy.

> Inspired by
> [Concurrent Core Data Stacks][Performance] article,
> [WWDC2013 Session 211][HighPerformance]
> and [Seru][Seru] CoreData stack by [@kostiakoval][User].

## Usage

Initialize `StorageModel` (see also: [StorageModel.md][StorageModel.md])

```swift
func newPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
    // Create and return new persistent store coordinator
}

let storage = StorageModel(persistentStoreCoordinator: newPersistentStoreCoordinator)
```


Initialize `Roku` stack (see also: [Roku.md][Roku.md]) with a base stack

```swift
let baseStack = Roku<BaseStack>(storage: storage)
```

or with a nested stack

```swift
let nestedStack = Roku<NestedStack>(storage: storage)
```

or with an independent stack.

```swift
let independentStack = Roku<IndependentStack>(storage: storage)
```

Enjoy `Roku`'s features :tada:

```swift
stack.mainObjectContext // Main queue managed object context

stack.withBackgroundContext { context in
    // Do heavy import operations on the background context
}

stack.persist { error -> Bool in
    // Handle an error and try fixing it
    
    // If error was successfully fixed, 
    // `Roku` will repeat save.
    return errorHandled && errorFixed
}
```

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

[User]:            https://github.com/kostiakoval
[Seru]:            https://github.com/kostiakoval/Seru

[Performance]:     http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/
[HighPerformance]: https://developer.apple.com/videos/play/wwdc2013-211/

[StorageModel.md]: Docs/StorageModel.md
[Roku.md]:         Docs/Roku.md