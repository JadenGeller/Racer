//
//  RacerTests.swift
//  RacerTests
//
//  Created by Jaden Geller on 10/21/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Racer

class RacerTests: XCTestCase {
    
    func testSemaphore() {
        let semaphore = Semaphore(value: 0)
        
        dispatch {
            semaphore.signal()
            semaphore.wait()
            semaphore.signal()
        }
        
        semaphore.wait()
        semaphore.signal()
        semaphore.wait()
    }
    
    func testMutex() {
        let mutex = Mutex()
        var array = [Int]()
        
        dispatch {
            mutex.acquire {
                for i in 0...5 {
                    array.append(i)
                    usleep(5)
                }
            }
        }
        
        usleep(5)
        
        dispatch {
            mutex.acquire {
                for i in 6...10 {
                    array.append(i)
                }
            }
        }
        
        // Let tests finish
        sleep(1)
        
        mutex.acquire {
            XCTAssertEqual(Array(0...10), array)
        }
    }
    
    func testRecursiveMutex() {
        let mutex = RecursiveMutex()
        
        func recursiveTester(x: Int) {
            mutex.acquire {
                if x > 0 { recursiveTester(x - 1) }
            }
        }
        
        // Doesn't deadlock!
        recursiveTester(10)
    }
    
    func testThreadLocal() {
        let unique = ThreadLocal(defaultValue: 0)
        
        dispatch {
            unique.localValue = 1
            
            dispatch {
                unique.localValue = 2

                XCTAssertEqual(2, unique.localValue)
            }
            
            usleep(20)
            
            XCTAssertEqual(1, unique.localValue)
        }
        
        usleep(50)
        
        XCTAssertEqual(0, unique.localValue)
    }
    
    func testMonitor() {
        let array = Monitor(bridgeFromValue: [])
        
        dispatch {
            array.acquire { array in
                
            }
        }
    }
}
