//
//  LogItLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 05/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class LogItLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogItLogger() {
        
        let session = URLSessionMock()
        
        let key = "aKey"
        
        let logger = LogItLogger(withKey: key)
        logger.session = session
        
        session.completionHandler = {
            XCTAssertEqual($0?.url?.absoluteString, LogItServiceConfig.httpsUri)
            XCTAssertEqual($0?.value(forHTTPHeaderField: LogItServiceConfig.headerApiKeyName), key)
            XCTAssertEqual($0?.value(forHTTPHeaderField: LogItServiceConfig.headerLogTypeName), logger.logLevel.simpleName)
            XCTAssertEqual($0?.value(forHTTPHeaderField: HTTPHeader.ContentType), HTTPHeader.ContentTypeJSON)
        }
        
        logger.log("Test")
        
    }
    
}
