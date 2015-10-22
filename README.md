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
