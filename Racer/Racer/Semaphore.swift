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
    
        Parameter value: The value with which to initialize the semaphore.
    */
    public init(value: Int = 0) {
        semaphore = dispatch_semaphore_create(value)
    }
    
    /** 
        Blocks the thread until the semaphore is free or for the specified timeout.

        Returns: True if the thread frees up, false if the timeout expires.
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
        Signals the sempahore.

        Returns: True if another thread was woken in response, false otherwise.
    **/
    public func signal() -> Bool {
        return dispatch_semaphore_signal(semaphore) != 0
    }
    
}
