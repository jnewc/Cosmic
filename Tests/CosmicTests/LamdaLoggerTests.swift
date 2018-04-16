//
//  LamdaLoggerTests.swift
//  CosmicTests
//
//  Created by Jack Newcombe on 16/04/2018.
//  Copyright © 2018 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LamdaLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLambdaLoggerAssignCompletion() {
        
        let expectation = self.expectation(description: "Completion is called")
        
        var line: UInt = 0
        
        let logger = LambdaLogger()
        logger.completion = { message, level, metadata in
            expectation.fulfill()
            XCTAssertEqual(message, "Test")
            XCTAssertEqual(level, .info)
            XCTAssertEqual(metadata.line, line)
            XCTAssertEqual("\(metadata.file)", "\(#file)")
        }
        
        line = UInt(#line) ; logger.info("Test")
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func testLambdaLoggerInitCompletion() {
        func testLambdaLogger() {
            
            let expectation = self.expectation(description: "Completion is called")
            
            var line: UInt = 0 
            
            let logger = LambdaLogger { message, level, metadata in
                expectation.fulfill()
                XCTAssertEqual(message, "Test")
                XCTAssertEqual(level, .info)
                XCTAssertEqual(metadata.line, line)
                XCTAssertEqual("\(metadata.file)", "\(#file)")
            }
            
            line = UInt(#line) ; logger.info("Test")
            
            self.waitForExpectations(timeout: 1.0, handler: nil)
            
        }
    }
    
}
