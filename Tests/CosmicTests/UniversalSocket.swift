//
//  UniversalSocket.swift
//  CosmicTests
//
//  Created by Jack Newcombe on 17/04/2018.
//  Copyright © 2018 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class UniversalSocketTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSocketSetup() {

        let config = SocketLoggerConfig(host: "", port: 8084, transport: .tcp)

        let socket = try! UniversalSocket(config: config)
        try! socket.listen()

        XCTAssert(socket.socket.isListening)
        XCTAssertEqual(socket.socket.remoteHostname, "0.0.0.0")
        XCTAssertEqual(socket.socket.listeningPort, 8084)
    }

}
