//
//  Mutex.swift
//  Racer
//
//  Created by Jaden Geller on 10/20/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public protocol MutexType {
    /**
        Acquires the mutex before executing the block and releases the mutex afterwards.
        For any given mutex, it is guarenteed that no two calls to `acquire` will happen
        at the same time regardless of what thread the call is made from.
    
        - Parameter block: The block to run while the mutex is acquired.
    
        - Returns: If the block returns some value, it will be propagated out of the function
        through this return value.
    */
    func acquire<ReturnValue>(block: () -> ReturnValue) -> ReturnValue
}

/// A basic `MutexType` that handles locking and unlocking automatically within the closure.
public class Mutex: MutexType {
    private let semaphore = Semaphore(value: 1)
    
    /**
        Acquires the mutex before executing the block and releases the mutex afterwards.
    
        - Parameter block: The block to run while the mutex is acquired.
    
        - Returns: If the block returns some value, it will be propagated out of the function
        through this return value.
    */
    public func acquire<ReturnValue>(block: () -> ReturnValue) -> ReturnValue {
        semaphore.wait()
        let returnValue = block()
        semaphore.signal()
        return returnValue
    }
}

/// A `MutexType` that handles doesn't become gridlocked on recursive usage.
public class RecursiveMutex: MutexType {
    private let mutex = Mutex()
    private var alreadyLocked = ThreadLocal(defaultValue: false)
    
    /**
        Acquires the mutex before executing the block and releases the mutex afterwards.
    
        - Parameter block: The block to run while the mutex is acquired. This block is allowed to recurse,
            or call another fuction that acquires the same mutex.
    
        - Returns: If the block returns some value, it will be propagated out of the function
        through this return value.
    */
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

/// A `MutexType` that combines many individual mutex together such that acquiring the
/// `MutexGroup` is equivalent to acquiring each individual mutex.
public class MutexGroup: MutexType {
    private let mutexes: [Mutex]
    
    init(mutexes: [Mutex]) {
        self.mutexes = mutexes
    }
    
    /**
        Acquires the group of mutexes before executing the block and releases the group afterwards.
    
        - Parameter block: The block to run while the mutexes are acquired.
    
        - Returns: If the block returns some value, it will be propagated out of the function
        through this return value.
    */
    public func acquire<ReturnValue>(block: () -> ReturnValue) -> ReturnValue {
        return mutexes.reduce(block) { nested, mutex in { mutex.acquire(nested) } }()
    }
}
