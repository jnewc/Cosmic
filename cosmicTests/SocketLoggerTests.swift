//
//  SocketLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 17/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class SocketLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSocketLogger_PaperTrail() {
        
        // TODO FIXME
        // This will currently send a log to a live papertrail system.
        
        let logger = SocketLogger()
        
        try! logger.socket.connect(toHost: "logs5.papertrailapp.com", onPort: 48441)
       
        logger.log("Test")
        
        sleep(5)
    }
    
}
