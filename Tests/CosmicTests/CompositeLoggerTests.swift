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
        logger.logLevel = .debug
        
        assertLoggerHasMessage(logger: logger, loggers: [logger1, logger2, logger3], level: .debug, message: "Test Debug")
        assertLoggerHasMessage(logger: logger, loggers: [logger1, logger2, logger3], level: .info, message: "Test Info")
        assertLoggerHasMessage(logger: logger, loggers: [logger1, logger2, logger3], level: .warn, message: "Test Warn")
        assertLoggerHasMessage(logger: logger, loggers: [logger1, logger2, logger3], level: .error, message: "Test Error")
    }
    
    func assertLoggerHasMessage(logger: CompositeLogger, loggers: [MemoryLogger], level: LogLevel, message: String) {
        
        logger.log(message, logLevel: level, metadata: LogMetadata())
        XCTAssertEqual(loggers[0].cache.entriesFor(logLevel: level).first!.message, message)
        XCTAssertEqual(loggers[1].cache.entriesFor(logLevel: level).first!.message, message)
        XCTAssertEqual(loggers[2].cache.entriesFor(logLevel: level).first!.message, message)
    }
    
    
    func testCompositeLoggerEmpty() {

        let logger = CompositeLogger()
        
        XCTAssertEqual(logger.formatters.count, 0)
    }
    
    func testCompositeLoggerLogLevel() {
        
        let logger1 = MemoryLogger()
        let logger2 = MemoryLogger()
        let logger3 = MemoryLogger()
        
        let logger = CompositeLogger(loggers: logger1, logger2, logger3)
        
        [LogLevel](arrayLiteral: .debug, .info, .warn, .error).forEach {
            logger.logLevel = $0
            
            XCTAssertEqual(logger1.logLevel, $0)
            XCTAssertEqual(logger2.logLevel, $0)
            XCTAssertEqual(logger1.logLevel, $0)
        }
        
    }
    
}
