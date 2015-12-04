//
//  ThreadSpecific.swift
//  Racer
//
//  Created by Jaden Geller on 12/3/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Darwin

private struct Recomputable<Value> {
    private var backing: Value
    private let recomputeValue: () -> Value
    
    init(value: Value? = nil, recomputeValue: () -> Value) {
        self.recomputeValue = recomputeValue
        self.backing = value ?? recomputeValue()
    }
    
    mutating func recompute() {
        backing = recomputeValue()
    }
    
    var value: Value {
        return backing
    }
}

/// A value that, after traversing thread boundries, must be recomputed (on access).
/// Note that `ThreadSpecific` does not provide any `Locker`-like concurrency support.
public struct ThreadSpecific<Value> {
    private var threadId = pthread_self()
    private var backing: Recomputable<Value>
    
    public init(value: Value? = nil, recomputeValue: () -> Value) {
        self.backing = Recomputable(value: value, recomputeValue: recomputeValue)
    }
    
    /// Since the value is recomputed on access when a `ThreadSpecific` value jumps thread,
    /// the value cannot be accessed unless declared `var`, not `let`.
    public var value: Value {
        mutating get {
            if threadId != pthread_self() {
                threadId = pthread_self()
                backing.recompute()
            }
            return backing.value
        }
    }
}
