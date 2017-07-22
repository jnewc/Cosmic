func createMetadata() -> LogMetadata { return LogMetadata() }
func createLog(_ logger: Logger) { logger.info("A log") }

//
//  LogMetadataTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 21/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LogMetadataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMetadata() {
        
        let metadata = createMetadata()
        
        XCTAssertEqual(metadata.file.description.components(separatedBy: "/").last, "LogMetadataTests.swift")
        XCTAssertEqual(metadata.function.description, "createMetadata()")
        XCTAssertEqual(metadata.line, 1)
    }
    
    func testMetadataInMemoryLogger() {
        
        let logger = MemoryLogger()
        
        createLog(logger)
        logger.logLevel = .info
        
        let entry = logger.cache.entriesFor(logLevel: .info).first!
        let metadata = entry.metadata
        
        XCTAssertEqual(entry.logLevel, .info)
        XCTAssertEqual(entry.message, "A log")
        
        XCTAssertEqual(metadata.file.description.components(separatedBy: "/").last, "LogMetadataTests.swift")
        XCTAssertEqual(metadata.function.description, "createLog")
        XCTAssertEqual(metadata.line, 2)
    }

    
}
