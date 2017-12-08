//
//  ExtensionsTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 09/11/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class ExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDispatchQueueUniqueness() {
        let queue1 = DispatchQueue(uniqueWithLabel: "label")
        let queue2 = DispatchQueue(uniqueWithLabel: "label")
        
        XCTAssertNotEqual(queue1.label, queue2.label)
    }
    
}
