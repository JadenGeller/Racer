//
//  Dispatcher.swift
//  Racer
//
//  Created by Jaden Geller on 10/21/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Dispatch

// Calls the passed in function or closure on a background thread. Equivalent
// to Go's "go" keyword.
public func dispatch(routine: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), routine)
}

// Calls the passed in function or closure on the main thead. Important for
// UI work!
public func main(routine: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), routine)
}
