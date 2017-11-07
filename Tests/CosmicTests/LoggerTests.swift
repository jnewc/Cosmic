//
//  LoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 08/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleName() {
        
        
        let logger = PrintLogger()
        
        logger.logLevel = .debug
        XCTAssertEqual(logger.logLevel.simpleName, "debug")
        
        logger.logLevel = .info
        XCTAssertEqual(logger.logLevel.simpleName, "info")
        
        logger.logLevel = .warn
        XCTAssertEqual(logger.logLevel.simpleName, "warn")
        
        logger.logLevel = .error
        XCTAssertEqual(logger.logLevel.simpleName, "error")
        
    }
    
    func testFormatters() {
        
        let logger = MemoryLogger()
        logger.logLevel = .info
        
        logger.formatters.append(BasicLogFormatter(prefix: "Prefix "))
        
        logger.info("Message")
        
        let entries = logger.cache.entriesFor(logLevel: .info)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.message, "Prefix Message")
    }
    
}
