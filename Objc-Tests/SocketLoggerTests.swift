//
//  SocketLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 17/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
import Socket

@testable import Cosmic

class SocketLoggerTests: XCTestCase {
    
    //typealias DidReadClosure = (_ sock: GCDAsyncUdpSocket, _ data: Data) -> ()
    
    //var didReadClosure: DidReadClosure?
    
    let asyncQueue = DispatchQueue(label: "test")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func server(transport: UniversalSocketTransport, on port: Int32, callback: @escaping (Data?) -> ()) -> UniversalSocket {
        // Connect server socket to receive logs on
        let config = SocketLoggerConfig(host: "127.0.0.1", port: port, transport: transport)
        let serverSocket = try! UniversalSocket(config: config)
        try! serverSocket.listen()
        try! serverSocket.read { data in
            callback(data)
        }
        return serverSocket

    }
    
    
    /// Verifies that messages are sent as expected over a socket
    func testUdpSocketLoggerDispatchSingleLog() {
        
        // Generate a random port to listen / connect on
        let interface =  "127.0.0.1"
        let port: Int = Int(arc4random() % UInt32(UInt16.max - 1024)) + 1024

        let expected = expectation(description: "")
        let _ = server(transport: .udp, on: Int32(port)) { data in
            XCTAssertEqual(data, "Test".data(using: .utf8))
            expected.fulfill()
       }
        
        sleep(1)
        
        // SUT
        let config = SocketLoggerConfig(host: interface, port: Int32(port), transport: .udp)
        let logger = SocketLogger(config: config)
        
        logger.log("Test")
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    /// Verifies that messages are sent as expected over a socket
    func testTcpSocketLoggerDispatchSingleLog() {
        
        // Generate a random port to listen / connect on
        let interface =  "127.0.0.1"
        let port: Int = Int(arc4random() % UInt32(UInt16.max - 1024)) + 1024
        
        let expected = expectation(description: "")
        let _ = server(transport: .tcp,  on: Int32(port)) { data in
            XCTAssertEqual(data, "Test".data(using: .utf8))
            expected.fulfill()
        }
        
        sleep(1)
        
        // SUT
        let config = SocketLoggerConfig(host: interface, port: Int32(port), transport: .tcp)
        let logger = SocketLogger(config: config)
        
        logger.log("Test")
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    
}
