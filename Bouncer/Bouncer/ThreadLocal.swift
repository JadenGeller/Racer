//
//  Thread.swift
//  Racer
//
//  Created by Jaden Geller on 10/21/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Dispatch

/**
    A type whose `localValue` member has independent values on each thread. Often used to represent local state
    of a given thread.

    Note that if an instance of `ThreadLocal` has its value assigned on a given thread, it MUST live at least as
    long as the thread.
*/
public class ThreadLocal<Value> {
    // Associates the pointer to the identifier (known by the thread) with the value
    private var allValues = [KeyIdentifier : Value]()

    private let mutex = Mutex()
    private let key: pthread_key_t
    private let defaultValue: Value

    /**
        The value associated with the current thread for this instance of `ThreadUnique`, so the 
        `defaultValue` if none has been associated.
    */
    public var localValue: Value {
        get {
            if let identifier = key.identifier {
                return allValues[identifier]!
            } else {
                return defaultValue
            }
        }
        set {
            if let identifier = key.identifier {
                allValues[identifier] = newValue
            } else {
                let identifier = UnsafeMutablePointer<KeyInfo>.alloc(1)
                
                // Teach the identifier how to clean up itself in case the
                //  thread finishes and the variable has to be deallocated
                identifier.initialize(KeyInfo(cleanUp: { [weak self] in
                    self?.allValues.removeValueForKey(identifier)
                    identifier.destroy()
                    identifier.dealloc(1)
                }))
                
                // Associate the identifier with the value
                allValues[identifier] = newValue
                
                // Associate the thread with the identifier
                key.identifier = KeyIdentifier(identifier)
            }
        }
    }
    
    /**
        Creates an instance of `ThreadLocal` that will return `defaultValue` when a value hasn't yet been assigned.
    */
    public init(defaultValue: Value) {
        var tempKey: pthread_key_t = 0
        guard pthread_key_create(&tempKey, cleanThreadLocalValue) == 0 else { fatalError("Unable to create key.") }
        self.key = tempKey
        self.defaultValue = defaultValue
    }
    
    deinit {
        pthread_key_delete(key)
        allValues.keys.map{ $0.memory }.forEach{ $0.cleanUp() } // Dealloc
    }
}

/**
    Creates an instance of `ThreadLocal` that will return `nil` when a value hasn't yet been assigned.
*/
public extension ThreadLocal where Value: NilLiteralConvertible {
    public convenience init() {
        self.init(defaultValue: nil)
    }
}

private extension pthread_key_t {
    private var identifier: KeyIdentifier? {
        get {
            let identifier = KeyIdentifier(pthread_getspecific(self))
            return identifier != nil ? identifier : .None
        }
        nonmutating set {
            assert(identifier == nil)
            pthread_setspecific(self, newValue!)
        }
    }
}

// In addition to being used as an identifier, the pointer also allows a thread to call cleanUp
typealias KeyIdentifier = UnsafePointer<KeyInfo>
class KeyInfo {
    let cleanUp: () -> ()
    
    init(cleanUp: () -> ()) {
        self.cleanUp = cleanUp
    }
}

// This function must be @convention(C), which is why we have to use the gross KeyIdentifier type
// instead of some nice generic thing. The `ThreadUnique` is REQUIRED to figure out the actual value
// since nobody else can knows the type.
private func cleanThreadLocalValue(runtimeValuePointer: UnsafeMutablePointer<Void>) {
    let identifier = KeyIdentifier(runtimeValuePointer).memory
    identifier.cleanUp()
}
