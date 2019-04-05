//
//  PrintLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class AssertionOutputStream: LogOutputStream {
    
    var output = ""
    
    var array: [String] {
        if output.contains("\n") {
            return output.components(separatedBy: "\n")
        } else {
            return output.isEmpty ? [] : [output]
        }
    }
    
    override init() {
        
    }
    
    override func write(_ string: String) {
        output += string
    }
    
}

class PrintLoggerTests: XCTestCase {
    
    let logs: [String] = [
        "This is a log",
        "®©℗™℠№ªº",
        "😀😡👹😨🤠😎"
    ]
    
    var printLogger = PrintLogger()

    var stream = AssertionOutputStream()

    override func setUp() {
        super.setUp()

        printLogger = PrintLogger()

        stream = AssertionOutputStream()

        printLogger.stream = stream
        printLogger.errorStream = stream
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Log level enabled tests
    
    func testDebugEnabled() {
        
        printLogger.logLevel = .debug
        
        logs.forEach {
            printLogger.debug($0)
            XCTAssertEqual(stream.array[logs.firstIndex(of: $0)!], $0)
        }

    }
    
    func testInfoEnabled() {
        
        printLogger.logLevel = .info
        
        logs.forEach {
            printLogger.info($0)
            XCTAssertEqual(stream.array[logs.firstIndex(of: $0)!], $0)
        }
        
    }
    
    func testWarnEnabled() {
        
        printLogger.logLevel = .warn
        
        logs.forEach {
            printLogger.warn($0)
            XCTAssertEqual(stream.array[logs.firstIndex(of: $0)!], $0)
        }
        
    }
    
    func testErrorEnabled() {
        
        printLogger.logLevel = .error
        
        logs.forEach {
            printLogger.error($0)
            XCTAssertEqual(stream.array[logs.firstIndex(of: $0)!], $0)
        }
        
    }
    
    // Log level implicit tests
    
    func testDebugImplicit() {
        
        printLogger.logLevel = .debug
        
        logs.forEach {
            printLogger.info($0)
            XCTAssertEqual(stream.array[logs.firstIndex(of: $0)!], $0)
        }
    }
    
    // Log level disabled tests
    
    func testDebugDisabled() {
        
        printLogger.logLevel = .info
        
        logs.forEach {
            printLogger.debug($0)
            XCTAssertFalse(stream.array.contains($0))
        }
        
    }
    
    func testLogDisabled() {
        
        printLogger.logLevel = .warn
        
        logs.forEach {
            printLogger.info($0)
            XCTAssertFalse(stream.array.contains($0))
        }
        
    }
    
    
    func testWarnDisabled() {
        
        printLogger.logLevel = .error
        
        logs.forEach {
            printLogger.warn($0)
            XCTAssertFalse(stream.array.contains($0))
        }
        
    }
    
    func testErrorDisabled() {
        
        printLogger.logLevel = .none
        
        logs.forEach {
            printLogger.error($0)
            XCTAssertFalse(stream.array.contains($0))
        }
        
    }
}
