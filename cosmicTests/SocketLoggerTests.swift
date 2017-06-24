//
//  SocketLoggerTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 17/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
import CocoaAsyncSocket

@testable import Cosmic

class SocketLoggerTests: XCTestCase, GCDAsyncUdpSocketDelegate {
    
    typealias DidReadClosure = (_ sock: GCDAsyncUdpSocket, _ data: Data) -> ()
    
    var didReadClosure: DidReadClosure?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    /// Verifies that messages are sent as expected over a socket
    func testSocketLoggerDispatchSingleLog() {
        
        // Generate a random port to listen / connect on
        let interface =  "127.0.0.1"
        let port = UInt16(arc4random() % (UInt32(UInt16.max) - 1024)) + 1024

        // SUT
        let config = SocketLoggerConfig(host: interface, port: port)
        let logger = SocketLogger(config: config)

        // Connect server socket to receive logs on
        let serverSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "com.cosmic.server.socket"))
        do {
            try serverSocket.bind(toPort: port, interface: interface)
            try serverSocket.beginReceiving()
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
        let expected = self.expectation(description: "Server socket will receive log")
        
        // The closure will be called when the server socket receives logs
        didReadClosure = { _, data in
            let text = String(data: data, encoding: .utf8)

            XCTAssert(text == "Test")
            expected.fulfill()
        }
        
        logger.log("Test")
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        didReadClosure?(sock, data)
    }
    
}
