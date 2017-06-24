//
//  CompositeLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 23/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class CompositeLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompositeLogger() {
        
        let logger1 = MemoryLogger()
        let logger2 = MemoryLogger()
        let logger3 = MemoryLogger()
        
        let logger = CompositeLogger(loggers: logger1, logger2, logger3)
        
        logger.log("Test")
        
        XCTAssertEqual(logger1.cache.entriesFor(logLevel: .info).first!.messages.first!, "Test")
        XCTAssertEqual(logger2.cache.entriesFor(logLevel: .info).first!.messages.first!, "Test")
        XCTAssertEqual(logger3.cache.entriesFor(logLevel: .info).first!.messages.first!, "Test")
    }
    
    func testCompositeLoggerEmpty() {

        let logger = CompositeLogger()
        
        XCTAssertEqual(logger.formatters.count, 0)
    }
    
}
