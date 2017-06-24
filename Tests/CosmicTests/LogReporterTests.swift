//
//  LogReporterTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 04/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LogReporterTests: XCTestCase, DefaultLogReporter {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultLogger() {
        
        let loggerWithClass = self.createLogger(with: PrintLogger.self)
        
        let a = String(describing: type(of: self.logger))
        let b = String(describing: type(of: loggerWithClass))
        
        XCTAssertEqual(a, b)
        
    }
}
