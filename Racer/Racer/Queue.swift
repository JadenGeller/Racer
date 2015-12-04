//
//  Queue.swift
//  Racer
//
//  Created by Jaden Geller on 10/22/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Dispatch

/**
    Execute closure asynchronously on a background thread.

    - Parameter block: The block to execute.
*/
public let dispatch = Queue.global.dispatch

/**
    Execute closure synchronously on a background thread.

    - Parameter block: The block to execute.
*/
public let dispatchSync = Queue.global.dispatchSync

/**
    Execute closure asynchronously on a background thread, but first
    wait for all other blocks submitted to the queue before it to complete
    and make all blocks submitted after it wait.

    - Parameter block: The block to execute.
*/
public let barrier = Queue.main.barrier

/// A queue that allows for ascnchronous execution of blocks.
public class Queue {
    
    /// The type of dipatch `Queue`.
    public enum Type {
        case Serial
        case Concurrent
        
        private var attribute: dispatch_queue_attr_t {
            switch self {
            case .Serial:     return DISPATCH_QUEUE_SERIAL
            case .Concurrent: return DISPATCH_QUEUE_CONCURRENT
            }
        }
    }
    
    private let backing: dispatch_queue_t
    
    public init(type: Type) {
        self.backing = dispatch_queue_create(nil, type.attribute)
    }
    
    private init(queue: dispatch_queue_t) {
        self.backing = queue
    }
    
    /// The shared main queue.
    public static var main = Queue(queue:  dispatch_get_main_queue())
    
    /// The shared global queue.
    public static var global = Queue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

    /**
        Execute closure block aynchronously.
    
        - Parameter block: The block to execute.
    */
    public func dispatch(block: () -> ()) {
        dispatch_async(backing, block)
    }
    
    /**
        Execute closure block synchronously.
     
        - Parameter block: The block to execute.
     */
    public func dispatchSync(block: () -> ()) {
        dispatch_sync(backing, block)
    }
    
    /**
        Execute closure aynchronously, but first wait for all other blocks
        submitted to the queue before it to complete and make all blocks submitted
        after it wait.
    
        - Parameter block: The block to execute.
    */
    public func barrier(isSynchronous isSynchronous: Bool = false, block: () -> ()) {
        if isSynchronous {
            dispatch_barrier_sync(backing, block)
        } else {
            dispatch_barrier_async(backing, block)
        }
    }
}
