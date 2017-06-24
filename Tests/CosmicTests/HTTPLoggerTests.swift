//
//  HTTPLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 24/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class MockURLSession: URLSession {
    
    
    
}

class HTTPLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each tevarmethod in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHTTPLoggerConfig() {

        let loggingUrl = "http://127.0.0.1:8089/log"
        let loggingMethod = "GET"
        let log = "Test"
        
        let expected = self.expectation(description: "Expect to receive log in server")

        let config = HTTPLoggerConfig(
            url: loggingUrl,
            method: loggingMethod,
            query: ["search": "term", "charset": "utf-8"],
            headers: [ "Content-Type": "text/plain" ]
        )
        
        // SUT
        let logger = HTTPLogger(config: config)
        
        let session = URLSessionMock()
        session.completionHandler = { request in
            expected.fulfill()
            XCTAssertEqual(request?.url?.absoluteString, logger.config?.urlWithQuery)
            XCTAssertEqual(request?.httpMethod, loggingMethod)
            XCTAssertEqual(String(data: request!.httpBody!, encoding: .utf8), log)
            XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "text/plain")
        }
        logger.session = session

        logger.log(log)
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
}
