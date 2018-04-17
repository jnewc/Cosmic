//
//  LogFilterTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 15/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LogFilterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        LogFilters.global.clearFilters()
    }
    
    func testClassLogFilterNoFilters() {
        
        let logger = MemoryLogger()
        
        let filter = ClassBasedLogFilter()
        
        LogFilters.global.addFilter(filter: filter)
        
        logger.info("This is a log")
        
        let entries = logger.cache.entriesFor(logLevel: .info)
        XCTAssertEqual(entries.first!.message, "This is a log")
        
    }
    
    func testClassLogFilterIncludedOverridesExcluded() {
        
        let logger = MemoryLogger()
        
        let filter = ClassBasedLogFilter()
        
        LogFilters.global.addFilter(filter: filter)
        
        // Included overrides Excluded
        filter.include(type: MemoryLogger.self, logLevel: .info)
        filter.exclude(type: MemoryLogger.self, logLevel: .info)
        
        logger.info("This is a log")
        
        let entries = logger.cache.entriesFor(logLevel: .info)
        XCTAssertEqual(entries.first?.message, "This is a log")
        
    }
    
    func testClassLogFilterExcluded() {
    
        let logger = MemoryLogger()
        
        let filter = ClassBasedLogFilter()
        
        LogFilters.global.addFilter(filter: filter)
        
        filter.exclude(type: MemoryLogger.self, logLevel: .info)
        
        logger.info("This is a log")
        
        let entries = logger.cache.entriesFor(logLevel: .info)
        XCTAssert(entries.isEmpty)
        
    }
    
    func testClassLogFilterIncluded() {
        
        let memoryLogger = MemoryLogger()
        let printLogger = PrintLogger()
        
        let filter = ClassBasedLogFilter()
        
        LogFilters.global.addFilter(filter: filter)
        
        filter.include(type: PrintLogger.self, logLevel: .info)
        
        memoryLogger.info("This is a log")
        
        let entries = memoryLogger.cache.entriesFor(logLevel: .info)
        XCTAssert(entries.isEmpty)
        
    }
    
}
