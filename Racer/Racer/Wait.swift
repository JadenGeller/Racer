//
//  WaitGroup.swift
//  Racer
//
//  Created by Jaden Geller on 10/21/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Dispatch

/**
    Wait for all the dispatched functions to execute before returning.

    - Parameter context: Function that takes the dispatch function as argument.
        All dispatch invocations that use this passed in dispatch function will
        be part of this dispatch block, and will thus `wait` will not return
        until each of these functions completes.
*/
public func wait(context: (dispatch: (() -> ()) -> ()) -> ()) {
    let group = dispatch_group_create()
    let global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    context { block in
        dispatch_group_async(group, global, block)
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
}
