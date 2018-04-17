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
    
    func testBasicLogFormatter() {
        
        let formatter = BasicLogFormatter()
        
        let string = formatter.format(message: "a", metadata: LogMetadata()); let line = #line
        
        XCTAssertEqual(string, "[FormatterTests.swift → testBasicLogFormatter():\(line)] a")
    }
    
    func testBasicLogFormatterWithPrefixAndSuffix() {
        
        let formatter = BasicLogFormatter(prefix: "a", suffix: "c")
        
        let string = formatter.format(message: "b", metadata: LogMetadata()); let line = #line
        
        XCTAssertEqual(string, "[FormatterTests.swift → testBasicLogFormatterWithPrefixAndSuffix():\(line)] abc")
        
    }
    
    func testSyslogFormatter() {
       
        let formatter = SyslogFormatter()

        let formattedMessage = formatter.format(message: "Testing", metadata: LogMetadata())
        
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
        
        let formattedMessage = formatter.format(message: "Test", metadata: LogMetadata())
        
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
        
        let message1 = formatter.format(message: "Message #1", metadata: LogMetadata())
        XCTAssertEqual(message1, "{\"id\":1,\"message\":\"Message #1\"}")

        let message2 = formatter.format(message: "Message #2", metadata: LogMetadata())
        XCTAssertEqual(message2, "{\"id\":2,\"message\":\"Message #2\"}")

        let message3 = formatter.format(message: "Message #3", metadata: LogMetadata())
        XCTAssertEqual(message3, "{\"id\":3,\"message\":\"Message #3\"}")

    }
    
    func testBlockFormatter() {
        
        let blockFormatter = LambdaFormatter { message, _ in
            return "« \(message) »"
        }
        
        let formattedMessage = blockFormatter.format(message: "Test", metadata: LogMetadata())
        
        XCTAssertEqual("« Test »", formattedMessage)
    }
    
    func testDateFormatter() {        
        let dateFormatter = DateLogFormatter()

        let formattedMessage = dateFormatter.format(message: "Test", metadata: LogMetadata()); let line = #line

        // TODO
        XCTAssertMatches(input: formattedMessage, pattern: "\\[FormatterTests\\.swift → testDateFormatter\\(\\):\(line)\\] \(dateTimeExpr) Test")
    }
    
    // MARK: Batch formatters
    
    func testNewLineBatchFormatter() {
        
        let batchFormatter = NewLineBatchFormatter()
        
        let formattedMessage = batchFormatter.format(batch: [
            ("Test1", LogMetadata()),
            ("Test2", LogMetadata()),
            ("Test3", LogMetadata())
        ])
        
        XCTAssertEqual("Test1\nTest2\nTest3", formattedMessage)
        
    }
    
    func testJSONBatchFormatter() {
        
        let batchFormatter = JSONBatchFormatter { message -> JSONFormatterDictionary in
            return [
                "message": message
            ]
        }
        
        let formattedMessage = batchFormatter.format(batch: [
            ("Test1", LogMetadata()),
            ("Test2", LogMetadata()),
            ("Test3", LogMetadata())
        ])
        
        let template: (String) -> String = { "{\"message\":\"\($0)\"}" }
        
        XCTAssertEqual([template("Test1"), template("Test2"), template("Test3")].joined(separator: "\n"), formattedMessage)
    }
    
}
