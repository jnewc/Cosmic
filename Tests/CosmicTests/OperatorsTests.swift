//
//  OperatorsTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 08/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class OperatorsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testNilConditionalNoReturn() {
        
        let expected = expectation(description: "Closure will be called")
        
        let value: Int? = 1
            
        value => expected.fulfill()

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    
    func testNilConditionalWithReturn() {
        
        var value: Int? = 1
        
        value = (value => 2)
        
        XCTAssertEqual(value, 2)
    }
    
    func testNilConditionalWithNilReturn() {
        
        var value: Int? = nil
        
        value = (value => 1)
        
        XCTAssertNil(value)
    }

}
