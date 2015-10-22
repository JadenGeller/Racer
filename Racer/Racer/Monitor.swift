//
//  Monitor.swift
//  Racer
//
//  Created by Jaden Geller on 10/20/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public class Monitor<Element> {
    private var backing: Element
    private let mutex = Mutex()
    
    /**
        Create a thread-safe value from an existing value.
    
        Note that it is illegal to again use the passed-in value if the value is a class or
        has any member that is a class.
    */
    public init(bridgeFromValue value: Element) {
        self.backing = value
    }
    
    private func acquire<ReturnValue>(block: inout Element -> ReturnValue) -> ReturnValue {
        return mutex.acquire {
            return block(&self.backing)
        }
    }
}

/**
    Operate on a value in a thread-safe manner.

    Parameter a: The thread-safe value to be operate on.
    Parameter block: The block that takes in the value and potentially reads or mutates it.
*/
func acquire<A, ReturnValue>(a: Monitor<A>, block: (inout A) -> ReturnValue) -> ReturnValue {
    return a.acquire { (inout a: A) in
        block(&a)
    }
}

/**
    Operate on two values in a thread-safe manner.

    Parameter a: A thread-safe value to be operate on.
    Parameter b: A thread-safe value to be operate on.
    Parameter block: The block that takes in the value and potentially reads or mutates it.
*/
func acquire<A, B, ReturnValue>(a: Monitor<A>, _ b: Monitor<B>, block: (inout A, inout B) -> ReturnValue) -> ReturnValue {
    return a.acquire { (inout a: A) in
        b.acquire { (inout b: B) in
            block(&a, &b)
        }
    }
}

/**
    Operate on three values in a thread-safe manner.

    Parameter a: A thread-safe value to be operate on.
    Parameter b: A thread-safe value to be operate on.
    Parameter c: A thread-safe value to be operate on.
    Parameter block: The block that takes in the value and potentially reads or mutates it.
*/
func multiple<A, B, C, ReturnValue>(a: Monitor<A>, _ b: Monitor<B>, _ c: Monitor<C>, block: (inout A, inout B, inout C) -> ReturnValue) -> ReturnValue {
    return a.acquire { (inout a: A) in
        b.acquire { (inout b: B) in
            c.acquire { (inout c: C) in
                block(&a, &b, &c)
            }
        }
    }
}

/**
    Operate on four values in a thread-safe manner.

    Parameter a: A thread-safe value to be operate on.
    Parameter b: A thread-safe value to be operate on.
    Parameter c: A thread-safe value to be operate on.
    Parameter d: A thread-safe value to be operate on.
    Parameter block: The block that takes in the value and potentially reads or mutates it.
*/
func multiple<A, B, C, D, ReturnValue>(a: Monitor<A>, _ b: Monitor<B>, _ c: Monitor<C>, _ d: Monitor<D>, block: (inout A, inout B, inout C, inout D) -> ReturnValue) -> ReturnValue {
    return a.acquire { (inout a: A) in
        b.acquire { (inout b: B) in
            c.acquire { (inout c: C) in
                d.acquire { (inout d: D) in
                    block(&a, &b, &c, &d)
                }
            }
        }
    }
}

/**
    Operate on five values in a thread-safe manner.

    Parameter a: A thread-safe value to be operate on.
    Parameter b: A thread-safe value to be operate on.
    Parameter c: A thread-safe value to be operate on.
    Parameter d: A thread-safe value to be operate on.
    Parameter e: A thread-safe value to be operate on.
    Parameter block: The block that takes in the value and potentially reads or mutates it.
*/
func multiple<A, B, C, D, E, ReturnValue>(a: Monitor<A>, _ b: Monitor<B>, _ c: Monitor<C>, _ d: Monitor<D>, _ e: Monitor<E>, block: (inout A, inout B, inout C, inout D, inout E) -> ReturnValue) -> ReturnValue {
    return a.acquire { (inout a: A) in
        b.acquire { (inout b: B) in
            c.acquire { (inout c: C) in
                d.acquire { (inout d: D) in
                    e.acquire { (inout e: E) in
                        block(&a, &b, &c, &d, &e)
                    }
                }
            }
        }
    }
}
