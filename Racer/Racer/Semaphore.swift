//
//  Semaphore.swift
//  Racer
//
//  Created by Jaden Geller on 10/20/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Dispatch

public class Semaphore {
    
    private let semaphore: dispatch_semaphore_t
    
    /**
        Creates a semaphore with the given value.
    
        - Parameter value: The value with which to initialize the semaphore.
    */
    public init(value: Int = 0) {
        semaphore = dispatch_semaphore_create(value)
    }
    
    /** 
        Blocks the thread until the semaphore is free or for the specified timeout.

        - Returns: True if the thread frees up, false if the timeout expires.
    */
    public func wait(nanosecondTimeout: Int64) -> Bool {
        return dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, nanosecondTimeout)) != 0
    }
    
    /**
        Blocks the thread until the semaphore is free.
    */
    public func wait() {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    /**
        Signals the sempahore. Does not block.

        - Returns: True if another thread was woken in response, false otherwise.
    **/
    public func signal() -> Bool {
        return dispatch_semaphore_signal(semaphore) != 0
    }
    
}

struct CancelableSemaphoreError: ErrorType {
    let description = "Semaphore canceled"
}

public class CancelableSemaphore {
    let backing: Semaphore
    private(set) var canceled = Locker(bridgeFromValue: false)
    
    private func ensureNotCanceled() throws {
        guard !(canceled.acquire { (inout canceled: Bool) in canceled }) else { throw CancelableSemaphoreError() }
    }
    
    public init(value: Int = 0) {
        backing = Semaphore(value: value)
    }
    
    public func wait(nanosecondTimeout: Int64) throws -> Bool {
        try ensureNotCanceled()
        let result = backing.wait(nanosecondTimeout)
        try ensureNotCanceled()
        return result
    }
    
    public func wait() throws {
        try ensureNotCanceled()
        backing.wait()
        try ensureNotCanceled()
    }
    
    public func signal() throws -> Bool {
        try ensureNotCanceled()
        let result = backing.signal()
        try ensureNotCanceled()
        return result
    }

    public func cancel() {
        canceled.acquire { (inout canceled: Bool) in
            canceled = true
            
            // Release all waiting threads
            while self.backing.signal() { continue }
        }
    }
}