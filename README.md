# Racer

Racer is a Swift framework the provides powerful, easy-to-use concurrent synchronization primitives such as `Monitor`, `Muxtex`, and `Semaphore`. Racer also provides type-safe thread-local storage that's super easy to use.

For example, here's how thread-local storage can be used to implement Racer's `RecursiveMutex`:
```swift
public class RecursiveMutex: MutexType {
    private let mutex = Mutex()
    private var alreadyLocked = ThreadLocal(defaultValue: false)

    public func acquire<ReturnValue>(block: () -> ReturnValue) -> ReturnValue {
        if !alreadyLocked.localValue {
            alreadyLocked.localValue = true
            defer { alreadyLocked.localValue = false }
            return mutex.acquire(block)
        }
        else {
            // We already locked on this thread. We don't need to lock again.
            return block()
        }
    }
}
```

Our `ThreadLocal` variable `alreadyLocked` allows us to prevent locking the Mutex again if the acquire function is called again on this same thread. Without this, locking would cause a deadlike, and our program would halt.

`ThreadLocal` values are a fully type safe alternative to `NSThread`s `threadDictionary`. Additionally, `ThreadLocal` values are much more lightweight in use---imagine if we had to use a dictionary just to encode that single boolean! 

You might've noticed that Racer's mutex type doesn't have a lock function, but an `acquire` function. This is a much safer alternative in that you cannot forget to unlock afterwards. Everything inside the `acquire` block is protected.

```swift
let mutex = Mutex()

mutex.acquire {
    // This is all safe!
}
```

Another similiar type, `Monitor`, wraps any type such that access is automatically protected.

```swift
let safeArray = Monitor(bridgeFromValue: [1, 2, 3])

safeArray.acquire { array in
    // Safetly modify array
}

If you're looking for a more versitile concurrency mechansim, `Semaphore` is a very light abstraction over `dispatch_semamphore_t`, and it can be used to implement a wide variety of new structures.
