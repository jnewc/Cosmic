//
//  FormatterTests.swift
//  Cosmic
//
//  Created by Jack Newcombe on 22/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest
@testable import Cosmic

class FormatterTests: XCTestCase {
    
    let dateTimeExpr = "\\d{4}-\\d{2}-\\d{2}(T|\\s)\\d{2}:\\d{2}:\\d{2}(.\\d{2,4})?Z?"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSyslogFormatter() {
       
        let formatter = SyslogFormatter()

        let formattedMessage = formatter.format(message: "Testing")
        
        XCTAssertMatches(input: formattedMessage, pattern: "<\\d{2}>\\d \(dateTimeExpr) Cosmic Unknown - - - Testing")
    }
    
    func testJSONFormatter() {
        
        let formatter = JSONFormatter { message in
            return [
                "id": "123",
                "tag": "my tag",
                "message": message
            ]
        }
        
        let formattedMessage = formatter.format(message: "Test")
        
        let expectedMessage = "{\"id\":\"123\",\"message\":\"Test\",\"tag\":\"my tag\"}"
        
        XCTAssertEqual(expectedMessage, formattedMessage)
    }
    
    func testJSONFormatterDynamic() {
        
        var count = 0
        
        let formatter = JSONFormatter { message in
            count += 1
            return [
                "id": count,
                "message": message
            ]
        }
        
        let message1 = formatter.format(message: "Message #1")
        XCTAssertEqual(message1, "{\"id\":1,\"message\":\"Message #1\"}")

        let message2 = formatter.format(message: "Message #2")
        XCTAssertEqual(message2, "{\"id\":2,\"message\":\"Message #2\"}")

        let message3 = formatter.format(message: "Message #3")
        XCTAssertEqual(message3, "{\"id\":3,\"message\":\"Message #3\"}")

    }
    
    func testBlockFormatter() {
        
        let blockFormatter = BlockFormatter {
            return "« \($0) »"
        }
        
        let formattedMessage = blockFormatter.format(message: "Test")
        
        XCTAssertEqual("« Test »", formattedMessage)
    }
    
    func testDateFormatter() {
        
        let dateFormatter = DateLogFormatter()
        
        let formattedMessage = dateFormatter.format(message: "Test")
        
        // TODO
        XCTAssertMatches(input: formattedMessage, pattern: "\(dateTimeExpr) Test")
    }
    
    // MARK: Batch formatters
    
    func testNewLineBatchFormatter() {
        
        let batchFormatter = NewLineBatchFormatter()
        
        let formattedMessage = batchFormatter.format(batch: [ "Test1", "Test2", "Test3" ])
        
        XCTAssertEqual("Test1\nTest2\nTest3", formattedMessage)
        
    }
    
    func testJSONBatchFormatter() {
        
        let batchFormatter = JSONBatchFormatter { message -> JSONFormatterDictionary in
            return [
                "message": message
            ]
        }
        
        let formattedMessage = batchFormatter.format(batch: [ "Test1", "Test2", "Test3" ])
        
        let template: (String) -> String = { "{\"message\":\"\($0)\"}" }
        
        XCTAssertEqual([template("Test1"), template("Test2"), template("Test3")].joined(separator: "\n"), formattedMessage)
    }
    
}
