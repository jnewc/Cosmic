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

    func testLoggerClassName() {
        let name = self.className

        XCTAssertEqual(name, "LogReporterTests")
    }

    func testLoggerInSubclass() {
        let object = B()

        let loggerA = object.getLoggerA()
        let loggerB = object.getLoggerB()

        XCTAssert(loggerA === loggerB)
    }
}


class A: LogReporter {

    typealias DefaultLoggerType = PrintLogger

    func getLoggerA() -> Logger {
        return logger
    }

}

class B: A {

    func getLoggerB() -> Logger {
        return logger
    }

}
