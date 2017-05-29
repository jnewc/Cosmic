//
//  LogOutputStreamTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LogOutputStreamTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStandardOutputStream() {
        
        let logger = PrintLogger()
        
        let stream = StandardOutputStream()
        logger.stream = stream
        
        logger.log("test")
    }
    
}
